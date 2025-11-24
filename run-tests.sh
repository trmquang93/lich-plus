#!/bin/bash

# Script to run iOS tests with support for unit tests, UI tests, or both
# Usage: ./run-tests.sh [--unit|--ui|--all] [-h|--help]
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
SIMULATOR_DEVICE="iPhone 17 Pro"
UNIT_TEST_TARGET="lich-plusTests"
UI_TEST_TARGET="lich-plusUITests"

# Flags for which tests to run
RUN_UNIT=false
RUN_UI=false

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

EXAMPLES:
    ./run-tests.sh                  # Run all tests (default)
    ./run-tests.sh --unit           # Run only unit tests
    ./run-tests.sh --ui             # Run only UI tests

NOTES:
    - The script uses the iPhone 17 Pro simulator
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

# Get the booted simulator ID
get_booted_simulator_id() {
    xcrun simctl list devices available --json | \
        jq -r '.devices | .[] | .[] | select(.state == "Booted") | .udid' | \
        head -1
}

# Try to get booted simulator ID
SIMULATOR_ID=$(get_booted_simulator_id)
if [ -z "$SIMULATOR_ID" ]; then
    echo "=== ERROR ==="
    echo "No booted iOS simulator found."
    echo ""
    echo "Please boot a simulator first. You can do this by:"
    echo "  xcrun simctl boot <device-name>"
    echo "  # or open Xcode and boot a simulator from the device list"
    exit 1
fi

# Check if xcbeautify is available
if ! command -v xcbeautify &> /dev/null; then
    echo "=== WARNING ==="
    echo "xcbeautify is not installed. Tests will run but output may not be formatted."
    echo "To install: brew install xcbeautify"
    echo ""
    USE_XCBEAUTIFY=false
else
    USE_XCBEAUTIFY=true
fi

# Function to run a test target
run_tests() {
    local test_target=$1
    local test_name=$2

    echo ""
    echo "=== RUNNING $test_name ==="
    echo "Target: $test_target"
    echo "Workspace: $WORKSPACE"
    echo "Scheme: $SCHEME"
    echo "Simulator: $SIMULATOR_DEVICE (ID: $SIMULATOR_ID)"
    echo ""

    # Build xcodebuild command
    local xcodebuild_cmd="xcodebuild \
        -workspace $WORKSPACE \
        -scheme $SCHEME \
        -destination 'platform=iOS Simulator,id=$SIMULATOR_ID' \
        -only-testing $test_target \
        test"

    # Execute command with optional xcbeautify
    if [ "$USE_XCBEAUTIFY" = true ]; then
        eval "$xcodebuild_cmd" | xcbeautify
    else
        eval "$xcodebuild_cmd"
    fi

    if [ $? -ne 0 ]; then
        echo ""
        echo "=== ERROR ==="
        echo "$test_name failed"
        return 1
    fi

    return 0
}

# Run tests based on flags
TEST_FAILED=false

if [ "$RUN_UNIT" = true ]; then
    if ! run_tests "$UNIT_TEST_TARGET" "UNIT TESTS"; then
        TEST_FAILED=true
    fi
fi

if [ "$RUN_UI" = true ]; then
    if ! run_tests "$UI_TEST_TARGET" "UI TESTS"; then
        TEST_FAILED=true
    fi
fi

# Final summary
echo ""
echo "=== TEST SUMMARY ==="
if [ "$TEST_FAILED" = true ]; then
    echo "Some tests failed. Please review the output above."
    exit 1
else
    echo "All tests passed successfully!"
    exit 0
fi
