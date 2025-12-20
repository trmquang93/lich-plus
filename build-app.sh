#!/bin/bash

# Script to build iOS app and check for build errors
# Usage: ./build-app.sh [--clean] [-v|--verbose] [-h|--help]
#
# Device Selection Priority:
#   1. TEST_DEVICE_ID from .env file (if set)
#   2. Booted simulator (auto-selected)
#   3. Connected physical device (fallback)
#   4. Interactive selection from available simulators (if neither above)
#
# Examples:
#   ./build-app.sh                    # Build the app (quiet mode)
#   ./build-app.sh --verbose          # Build with full output
#   ./build-app.sh --clean            # Clean build folder first
#   ./build-app.sh --clean --verbose  # Clean and build verbosely
#   ./build-app.sh -h                 # Show help

set -eo pipefail

# Configuration
WORKSPACE="lich-plus.xcworkspace"
SCHEME="lich-plus"

# Flags
CLEAN_BUILD=false
VERBOSE_MODE=false

# Load environment file if it exists
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# Function to display help
show_help() {
    cat << EOF
iOS App Builder

Usage: ./build-app.sh [OPTIONS]

OPTIONS:
    --clean             Clean build folder before building
    -v, --verbose       Verbose mode: show full build output
    -h, --help          Display this help message

DEVICE SELECTION:
    The script automatically selects a build destination in this order:
    1. TEST_DEVICE_ID from .env file (if set)
    2. Booted simulator (if any simulator is currently running)
    3. Connected physical device (if a device is plugged in)
    4. Interactive menu (choose from available simulators)

EXAMPLES:
    ./build-app.sh                      # Build the app (quiet mode)
    ./build-app.sh --verbose            # Build with full output
    ./build-app.sh --clean              # Clean and build
    ./build-app.sh --clean --verbose    # Clean and build verbosely

NOTES:
    - Quiet mode (default) shows only BUILD SUCCEEDED or errors
    - Verbose mode shows full build output with all compilation steps
    - Output is piped through xcbeautify for clean formatting
    - Requires Xcode and CocoaPods to be installed
    - The workspace file must exist: $WORKSPACE

EOF
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        -v|--verbose)
            VERBOSE_MODE=true
            shift
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
done

# Validate workspace exists
if [ ! -d "$WORKSPACE" ]; then
    echo "=== ERROR ==="
    echo "Workspace not found: $WORKSPACE"
    echo ""
    echo "Please ensure you are running this script from the 'lich-plus' directory:"
    echo "  cd lich-plus"
    echo "  ./build-app.sh"
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
find_build_device() {
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
        if [ "$VERBOSE_MODE" = true ]; then
            echo "Using device from .env: $DEVICE_NAME ($DEVICE_TYPE)"
        fi
        return 0
    fi

    # Priority 1: Check for booted simulator
    local booted
    booted=$(get_booted_simulator)

    if [ -n "$booted" ]; then
        DEVICE_ID="${booted%%|*}"
        DEVICE_NAME="${booted#*|}"
        DEVICE_TYPE="simulator"
        if [ "$VERBOSE_MODE" = true ]; then
            echo "Found booted simulator: $DEVICE_NAME"
        fi
        return 0
    fi

    # Priority 2: Check for connected physical device
    local connected
    connected=$(get_connected_devices | head -1)

    if [ -n "$connected" ]; then
        DEVICE_ID="${connected%%|*}"
        DEVICE_NAME="${connected#*|}"
        DEVICE_TYPE="device"
        if [ "$VERBOSE_MODE" = true ]; then
            echo "Found connected device: $DEVICE_NAME"
        fi
        return 0
    fi

    # Priority 3: Interactive selection
    select_device_interactive
}

# Find the build device
if [ "$VERBOSE_MODE" = true ]; then
    echo "=== DEVICE DETECTION ==="
fi
find_build_device

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
    echo "xcbeautify is not installed. Build will run but output may not be formatted."
    echo "To install: brew install xcbeautify"
    echo ""
    USE_XCBEAUTIFY=false
else
    USE_XCBEAUTIFY=true
fi

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
    if [ "$VERBOSE_MODE" = true ]; then
        echo ""
        echo "=== CLEANING BUILD FOLDER ==="
    fi
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        clean >/dev/null 2>&1
    if [ "$VERBOSE_MODE" = true ]; then
        echo "Clean completed."
    fi
fi

# Build the app
if [ "$VERBOSE_MODE" = true ]; then
    echo ""
    echo "=== BUILDING APP ==="
    echo "Workspace: $WORKSPACE"
    echo "Scheme: $SCHEME"
    echo "Device: $DEVICE_NAME ($DEVICE_TYPE)"
    echo "Device ID: $DEVICE_ID"
    echo ""
fi

BUILD_EXIT_CODE=0
TEMP_OUTPUT=""

if [ "$VERBOSE_MODE" = true ]; then
    # Verbose mode - show all output through xcbeautify
    if [ "$USE_XCBEAUTIFY" = true ]; then
        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            build \
            2>&1 | xcbeautify || BUILD_EXIT_CODE=$?
    else
        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            build \
            2>&1 || BUILD_EXIT_CODE=$?
    fi
else
    # Quiet mode - capture output, show only result or errors
    TEMP_OUTPUT=$(mktemp)
    trap "rm -f $TEMP_OUTPUT" EXIT
    
    if [ "$USE_XCBEAUTIFY" = true ]; then
        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            build \
            2>&1 | xcbeautify > "$TEMP_OUTPUT" 2>&1 || BUILD_EXIT_CODE=$?
    else
        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            build \
            > "$TEMP_OUTPUT" 2>&1 || BUILD_EXIT_CODE=$?
    fi
fi

# Output results
if [ "$VERBOSE_MODE" = true ]; then
    echo ""
    if [ $BUILD_EXIT_CODE -eq 0 ]; then
        echo "=== BUILD SUCCEEDED ==="
    else
        echo "=== BUILD FAILED ==="
        exit $BUILD_EXIT_CODE
    fi
else
    # Quiet mode output
    if [ $BUILD_EXIT_CODE -eq 0 ]; then
        echo "BUILD SUCCEEDED"
    else
        # Show errors from temp file
        if [ -n "$TEMP_OUTPUT" ] && [ -f "$TEMP_OUTPUT" ]; then
            grep -E "(❌|error:|fatal error:)" "$TEMP_OUTPUT" 2>/dev/null || cat "$TEMP_OUTPUT"
        fi
        echo ""
        echo "BUILD FAILED"
        exit $BUILD_EXIT_CODE
    fi
fi
