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

set -euo pipefail

# Configuration
WORKSPACE="lich-plus.xcworkspace"
SCHEME="lich-plus"
UNIT_TEST_TARGET="lich-plusTests"
UI_TEST_TARGET="lich-plusUITests"

# Crash detection patterns
CRASH_PATTERNS="Fatal error:|RESOLVER:.*not resolved|EXC_BAD_ACCESS|SIGABRT|SIGKILL|Thread.*Crashed|NSInternalInconsistencyException|malloc:.*error|pointer being freed was not allocated"

# Flags for which tests to run
RUN_UNIT=false
RUN_UI=false
VERBOSE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# Load environment file if it exists
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    # Source the env file (export variables)
    set -a
    source "$ENV_FILE"
    set +a
fi

# Cleanup handler
cleanup() {
    rm -f /tmp/xcodebuild_output_$$.log
}
trap cleanup EXIT

# Function to display help
show_help() {
    cat << EOF
iOS Test Runner

Usage: ./run-tests.sh [OPTIONS]

OPTIONS:
    --unit              Run only unit tests
    --ui                Run only UI tests
    --all               Run all tests (unit + UI) - this is the default
    --verbose, -v       Show full xcodebuild output (default: show only summary)
    -h, --help          Display this help message

DEVICE SELECTION:
    The script automatically selects a test destination in this order:
    1. Booted simulator (if any simulator is currently running)
    2. Connected physical device (if a device is plugged in)
    3. Interactive menu (choose from available simulators)

EXAMPLES:
    ./run-tests.sh                  # Run all tests (shows "X/Y passed" on success)
    ./run-tests.sh --unit           # Run only unit tests
    ./run-tests.sh --ui             # Run only UI tests
    ./run-tests.sh --verbose        # Show full output for debugging
    ./run-tests.sh --unit -v        # Combine flags

OUTPUT:
    By default, shows only a summary (e.g., "42/42 tests passed").
    On failure, shows failed test names and error details.
    Use --verbose to see full xcodebuild output.

NOTES:
    - Requires Xcode and CocoaPods to be installed
    - The workspace file must exist: $WORKSPACE

EOF
}

# Parse command line arguments
while [ $# -gt 0 ]; do
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
        --verbose|-v)
            VERBOSE=true
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
    shift
done

# Default: run all tests if no test type specified
if [ "$RUN_UNIT" = false ] && [ "$RUN_UI" = false ]; then
    RUN_UNIT=true
    RUN_UI=true
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
    if [ -n "${TEST_DEVICE_ID:-}" ]; then
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
        if [ "$VERBOSE" = true ]; then
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
        if [ "$VERBOSE" = true ]; then
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
        if [ "$VERBOSE" = true ]; then
            echo "Found connected device: $DEVICE_NAME"
        fi
        return 0
    fi

    # Priority 3: Interactive selection
    select_device_interactive
}

# Find the test device
if [ "$VERBOSE" = true ]; then
    echo "=== DEVICE DETECTION ==="
fi
find_test_device

# Build destination string based on device type
if [ "$DEVICE_TYPE" = "simulator" ]; then
    DESTINATION="platform=iOS Simulator,id=$DEVICE_ID"
else
    DESTINATION="platform=iOS,id=$DEVICE_ID"
fi

# Check if xcbeautify is available
if ! command -v xcbeautify &> /dev/null; then
    if [ "$VERBOSE" = true ]; then
        echo ""
        echo "=== WARNING ==="
        echo "xcbeautify is not installed. Install with: brew install xcbeautify"
        echo ""
    fi
    USE_XCBEAUTIFY=false
else
    USE_XCBEAUTIFY=true
fi

# Function to run tests for a specific target with clean output
run_tests() {
    local test_target=$1
    local test_name=$2
    local temp_output="/tmp/xcodebuild_output_$$.log"
    local test_exit_code=0

    if [ "$VERBOSE" = true ]; then
        echo ""
        echo "=== RUNNING $test_name ==="
        echo "Target: $test_target"
        echo "Workspace: $WORKSPACE"
        echo "Scheme: $SCHEME"
        echo "Device: $DEVICE_NAME ($DEVICE_TYPE)"
        echo ""

        # Verbose mode: stream output through xcbeautify
        if [ "$USE_XCBEAUTIFY" = true ]; then
            xcodebuild \
                -workspace "$WORKSPACE" \
                -scheme "$SCHEME" \
                -destination "$DESTINATION" \
                -only-testing:"$test_target" \
                test \
                2>&1 | tee "$temp_output" | xcbeautify | grep -v "Compiling"
            test_exit_code=${PIPESTATUS[0]}
        else
            xcodebuild \
                -workspace "$WORKSPACE" \
                -scheme "$SCHEME" \
                -destination "$DESTINATION" \
                -only-testing:"$test_target" \
                test \
                2>&1 | tee "$temp_output"
            test_exit_code=${PIPESTATUS[0]}
        fi
    else
        echo -n "Running $test_name... "

        # Quiet mode: capture output silently
        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:"$test_target" \
            test \
            > "$temp_output" 2>&1
        test_exit_code=$?
    fi

    # Check for crashes in output
    if grep -qE "$CRASH_PATTERNS" "$temp_output" 2>/dev/null; then
        echo ""
        echo -e "${RED}=== CRASH DETECTED ===${NC}"
        grep -E "$CRASH_PATTERNS" "$temp_output" 2>/dev/null | head -10
        echo ""
        echo "Crash detected during tests. This may indicate:"
        echo "  - Swift assertion/precondition failure"
        echo "  - Memory access violation (EXC_BAD_ACCESS)"
        echo "  - Dependency injection failure"
        echo "  - Thread safety problems"
        rm -f "$temp_output"
        return 134
    fi

    # Check for build failures
    if grep -q "BUILD FAILED\|Compilation failed" "$temp_output" 2>/dev/null; then
        echo ""
        echo -e "${RED}Build failed${NC}"
        echo ""
        echo -e "${YELLOW}Build Errors:${NC}"
        grep -E "error:.*\.swift|fatal error:|.*\.swift:[0-9]+:[0-9]+: error:" "$temp_output" 2>/dev/null | head -15 | sed 's/^/   /'
        rm -f "$temp_output"
        return 1
    fi

    # Parse test results - handle both XCTest and Swift Testing formats
    local passed=0
    local failed=0

    # Use grep directly on file to avoid broken pipe errors with large outputs
    # Filter out xcodebuild debug output (lines starting with timestamps or containing [MT])
    if grep -v "^\[MT\]\|^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\|xcodebuild\[" "$temp_output" 2>/dev/null | grep -q "Test case.*passed\|Test case.*failed"; then
        # XCTest format: "Test case '-[TestClass testMethod]' passed"
        passed=$(grep -v "^\[MT\]\|xcodebuild\[" "$temp_output" 2>/dev/null | grep -c "Test case.*passed" || echo "0")
        failed=$(grep -v "^\[MT\]\|xcodebuild\[" "$temp_output" 2>/dev/null | grep -c "Test case.*failed" || echo "0")
    elif grep -q "Executed [0-9]* test" "$temp_output" 2>/dev/null; then
        # Parse from "Executed X tests, with Y failures" summary line
        local summary_line
        summary_line=$(grep "Executed [0-9]* test" "$temp_output" 2>/dev/null | tail -1)
        local total_tests
        total_tests=$(echo "$summary_line" | grep -o "Executed [0-9]*" | grep -o "[0-9]*" || echo "0")
        local failures
        failures=$(echo "$summary_line" | grep -o "with [0-9]* failure" | grep -o "[0-9]*" || echo "0")
        if [ -z "$failures" ]; then failures=0; fi
        if [ -z "$total_tests" ]; then total_tests=0; fi
        passed=$((total_tests - failures))
        failed=$failures
    else
        # Fallback: count Test Case lines
        passed=$(grep -c "Test Case.*passed" "$temp_output" 2>/dev/null || echo "0")
        failed=$(grep -c "Test Case.*failed" "$temp_output" 2>/dev/null || echo "0")
    fi

    # Clean up counts
    passed=$(echo "$passed" | tr -d ' \t\n\r')
    failed=$(echo "$failed" | tr -d ' \t\n\r')

    # Ensure numeric values
    if ! [[ "$passed" =~ ^[0-9]+$ ]]; then passed=0; fi
    if ! [[ "$failed" =~ ^[0-9]+$ ]]; then failed=0; fi

    local total=$((passed + failed))

    # Display results
    if [ "$failed" -eq 0 ] && [ "$total" -gt 0 ]; then
        echo -e "${GREEN}${passed}/${total} tests passed${NC}"
        rm -f "$temp_output"
        return 0
    elif [ "$total" -eq 0 ]; then
        echo -e "${YELLOW}No tests found${NC}"
        if [ "$VERBOSE" = true ]; then
            grep -E "Testing failed|BUILD FAILED|No tests|error:" "$temp_output" 2>/dev/null | head -10 | sed 's/^/   /'
        fi
        rm -f "$temp_output"
        return 1
    else
        echo -e "${RED}${passed}/${total} tests passed ($failed failed)${NC}"
        echo ""

        # Extract and display failed tests
        echo -e "${YELLOW}Failed tests:${NC}"

        local failed_tests
        if grep -q "Failing tests:" "$temp_output" 2>/dev/null; then
            # Use the "Failing tests:" section from xcodebuild output
            failed_tests=$(sed -n '/Failing tests:/,/^$/p' "$temp_output" | grep -E "^\s+\S+\.\S+" | sed 's/^\s*//')
        else
            # Extract from "Test case '-[Class method]' failed" lines, filtering out debug output
            failed_tests=$(grep -v "xcodebuild\[\|^\[MT\]" "$temp_output" 2>/dev/null | grep "Test case.*failed" | sed "s/.*Test case '\\(-\\[[^]]*\\]\\)' failed.*/\\1/" | sed "s/.*Test case '-\\[\\([^]]*\\)\\]' failed.*/\\1/")
        fi

        if [ -n "$failed_tests" ]; then
            while IFS= read -r test; do
                if [ -n "$test" ]; then
                    echo -e "   ${RED}$test${NC}"
                    # Try to extract failure reason
                    local method_name
                    method_name=$(echo "$test" | sed 's/.*\.//' | sed 's/ .*//' | sed 's/.*\s//')
                    if [ -n "$method_name" ]; then
                        local failure_line
                        failure_line=$(grep -v "xcodebuild\[" "$temp_output" 2>/dev/null | grep -E "XCTAssert.*failed|error:.*$method_name" | head -1)
                        if [ -n "$failure_line" ]; then
                            echo "      $(echo "$failure_line" | sed 's/^.*error: //' | head -c 200)"
                        fi
                    fi
                fi
            done <<< "$failed_tests"
        else
            echo "   (Could not extract failed test names)"
        fi

        echo ""
        rm -f "$temp_output"
        return 1
    fi
}

# Track overall test results
OVERALL_EXIT_CODE=0

# Run the requested tests
if [ "$RUN_UNIT" = true ]; then
    run_tests "$UNIT_TEST_TARGET" "Unit Tests" || OVERALL_EXIT_CODE=1
fi

if [ "$RUN_UI" = true ]; then
    run_tests "$UI_TEST_TARGET" "UI Tests" || OVERALL_EXIT_CODE=1
fi

# Show final summary only in verbose mode or on failure
if [ "$VERBOSE" = true ]; then
    echo ""
    if [ $OVERALL_EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}All tests completed successfully${NC}"
    else
        echo -e "${RED}Some tests failed${NC}"
    fi
fi

exit $OVERALL_EXIT_CODE
