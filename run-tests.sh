#!/bin/bash

# Script to run iOS tests with support for unit tests, UI tests, or both
# Usage: ./run-tests.sh [--unit|--ui|--all] [-h|--help]
#
# Device Selection Priority:
#   1. Booted simulator (auto-selected)
#   2. Connected physical device (fallback)
#   3. Interactive selection from available simulators (if neither above)
#
# Examples:
#   ./run-tests.sh                    # Run all tests (default)
#   ./run-tests.sh --unit             # Run only unit tests
#   ./run-tests.sh --ui               # Run only UI tests
#   ./run-tests.sh -h                 # Show help

set -e

# Configuration
WORKSPACE="lich-plus.xcworkspace"
SCHEME="lich-plus"
UNIT_TEST_TARGET="lich-plusTests"
UI_TEST_TARGET="lich-plusUITests"

# Flags for which tests to run
RUN_UNIT=false
RUN_UI=false

# Load environment file if it exists
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    # Source the env file (export variables)
    set -a
    source "$ENV_FILE"
    set +a
fi

# Function to display help
show_help() {
    cat << EOF
iOS Test Runner

Usage: ./run-tests.sh [OPTIONS]

OPTIONS:
    --unit              Run only unit tests
    --ui                Run only UI tests
    --all               Run all tests (unit + UI) - this is the default
    -h, --help          Display this help message

DEVICE SELECTION:
    The script automatically selects a test destination in this order:
    1. Booted simulator (if any simulator is currently running)
    2. Connected physical device (if a device is plugged in)
    3. Interactive menu (choose from available simulators)

EXAMPLES:
    ./run-tests.sh                  # Run all tests (default)
    ./run-tests.sh --unit           # Run only unit tests
    ./run-tests.sh --ui             # Run only UI tests

NOTES:
    - Output is piped through xcbeautify for clean formatting
    - Requires Xcode and CocoaPods to be installed
    - The workspace file must exist: $WORKSPACE

EOF
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    # Default: run all tests
    RUN_UNIT=true
    RUN_UI=true
else
    case "$1" in
        --unit)
            RUN_UNIT=true
            ;;
        --ui)
            RUN_UI=true
            ;;
        --all)
            RUN_UNIT=true
            RUN_UI=true
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'"
            echo ""
            show_help
            exit 1
            ;;
    esac
fi

# Validate workspace exists
if [ ! -d "$WORKSPACE" ]; then
    echo "=== ERROR ==="
    echo "Workspace not found: $WORKSPACE"
    echo ""
    echo "Please ensure you are running this script from the 'lich-plus' directory:"
    echo "  cd lich-plus"
    echo "  ./run-tests.sh"
    exit 1
fi

# Get the first booted simulator ID
get_booted_simulator() {
    xcrun simctl list devices available --json 2>/dev/null | \
        jq -r '.devices | to_entries[] | .value[] | select(.state == "Booted") | "\(.udid)|\(.name)"' | \
        head -1
}

# Get connected physical devices (iOS devices have version numbers like "iPhone (17.0) (UDID)")
# Only looks at the "== Devices ==" section, stops at "== Devices Offline ==" or "== Simulators =="
get_connected_devices() {
    xcrun xctrace list devices 2>/dev/null | \
        sed -n '/^== Devices ==$/,/^== /p' | \
        grep -v "^==" | \
        grep -E "^\S.*\([0-9]+\.[0-9]" | \
        sed -E 's/^(.*) \([0-9]+\.[0-9][^)]*\) \(([^)]+)\)$/\2|\1/'
}

# Get available simulators (iOS only, not booted)
get_available_simulators() {
    xcrun simctl list devices available --json 2>/dev/null | \
        jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.state != "Booted" and .isAvailable == true) | "\(.udid)|\(.name)"' | \
        head -20
}

# Function to select device interactively
select_device_interactive() {
    echo ""
    echo "=== SELECT A DEVICE ==="
    echo "No booted simulator or connected device found."
    echo ""

    # Get available simulators
    local simulators
    simulators=$(get_available_simulators)

    if [ -z "$simulators" ]; then
        echo "No available simulators found."
        echo "Please install simulators via Xcode > Settings > Platforms"
        exit 1
    fi

    # Build array of options
    local options=()
    local i=1

    echo "Available iOS Simulators:"
    echo ""
    while IFS='|' read -r udid name; do
        if [ -n "$udid" ]; then
            options+=("$udid|$name")
            printf "  %2d) %s\n" "$i" "$name"
            ((i++))
        fi
    done <<< "$simulators"

    echo ""
    read -p "Enter number (1-$((i-1))): " selection

    # Validate selection
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $((i-1)) ]; then
        echo "Invalid selection."
        exit 1
    fi

    # Get selected device
    local selected="${options[$((selection-1))]}"
    DEVICE_ID="${selected%%|*}"
    DEVICE_NAME="${selected#*|}"
    DEVICE_TYPE="simulator"

    # Boot the selected simulator
    echo ""
    echo "Booting simulator: $DEVICE_NAME..."
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
    sleep 2
}

# Try to find a device in priority order
find_test_device() {
    # Priority 0: Check for environment variable
    if [ -n "$TEST_DEVICE_ID" ]; then
        DEVICE_ID="$TEST_DEVICE_ID"
        # Auto-detect device type by checking if it's a simulator
        if xcrun simctl list devices --json 2>/dev/null | grep -q "\"udid\" : \"$DEVICE_ID\""; then
            DEVICE_TYPE="simulator"
            DEVICE_NAME=$(xcrun simctl list devices --json 2>/dev/null | \
                jq -r ".devices[][] | select(.udid == \"$DEVICE_ID\") | .name" | head -1)
        else
            DEVICE_TYPE="device"
            DEVICE_NAME="Physical Device"
        fi
        echo "Using device from .env: $DEVICE_NAME ($DEVICE_TYPE)"
        return 0
    fi

    # Priority 1: Check for booted simulator
    local booted
    booted=$(get_booted_simulator)

    if [ -n "$booted" ]; then
        DEVICE_ID="${booted%%|*}"
        DEVICE_NAME="${booted#*|}"
        DEVICE_TYPE="simulator"
        echo "Found booted simulator: $DEVICE_NAME"
        return 0
    fi

    # Priority 2: Check for connected physical device
    local connected
    connected=$(get_connected_devices | head -1)

    if [ -n "$connected" ]; then
        DEVICE_ID="${connected%%|*}"
        DEVICE_NAME="${connected#*|}"
        DEVICE_TYPE="device"
        echo "Found connected device: $DEVICE_NAME"
        return 0
    fi

    # Priority 3: Interactive selection
    select_device_interactive
}

# Find the test device
echo "=== DEVICE DETECTION ==="
find_test_device

# Build destination string based on device type
if [ "$DEVICE_TYPE" = "simulator" ]; then
    DESTINATION="platform=iOS Simulator,id=$DEVICE_ID"
else
    DESTINATION="platform=iOS,id=$DEVICE_ID"
fi

# Check if xcbeautify is available
if ! command -v xcbeautify &> /dev/null; then
    echo ""
    echo "=== WARNING ==="
    echo "xcbeautify is not installed. Tests will run but output may not be formatted."
    echo "To install: brew install xcbeautify"
    echo ""
    USE_XCBEAUTIFY=false
else
    USE_XCBEAUTIFY=true
fi

# Function to run tests for a specific target
run_tests() {
    local test_target=$1
    local test_name=$2
    local temp_output="/tmp/xcodebuild_output_$$.log"

    echo ""
    echo "=== RUNNING $test_name ==="
    echo "Target: $test_target"
    echo "Workspace: $WORKSPACE"
    echo "Scheme: $SCHEME"
    echo "Device: $DEVICE_NAME ($DEVICE_TYPE)"
    echo "Device ID: $DEVICE_ID"
    echo ""

    # Run tests and capture raw output to temp file while also displaying via xcbeautify
    if [ "$USE_XCBEAUTIFY" = true ]; then
        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing "$test_target" \
            test \
            2>&1 | tee "$temp_output" | xcbeautify | grep -v "Compiling"
    else
        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing "$test_target" \
            test \
            2>&1 | tee "$temp_output" | grep -v "Compiling"
    fi

    local test_exit_code=${PIPESTATUS[0]}

    # Check for malloc/memory errors in raw output
    if grep -q "malloc:.*error\|pointer being freed was not allocated" "$temp_output" 2>/dev/null; then
        echo ""
        echo "=== MEMORY ERROR DETECTED ==="
        grep -E "malloc:|pointer being freed" "$temp_output" | head -20
        echo ""
        echo "Memory corruption detected during tests. This may indicate:"
        echo "  - Third-party library issues"
        echo "  - iOS simulator version incompatibility"
        echo "  - Thread safety problems"
        echo ""
        rm -f "$temp_output"
        exit 1
    fi

    rm -f "$temp_output"
    return $test_exit_code
}

# Run the requested tests
if [ "$RUN_UNIT" = true ]; then
    run_tests "$UNIT_TEST_TARGET" "UNIT TESTS"
fi

if [ "$RUN_UI" = true ]; then
    run_tests "$UI_TEST_TARGET" "UI TESTS"
fi

echo ""
echo "=== ALL TESTS COMPLETED ==="
