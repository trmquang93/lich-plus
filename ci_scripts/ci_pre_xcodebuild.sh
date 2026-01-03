#!/bin/sh

# Xcode Cloud Pre-Xcodebuild Script
# Runs immediately before xcodebuild archive/build command
# Used for last-minute setup before the build starts

set -e

echo "Pre-Xcodebuild: Starting..."

# Detect project root
if [ -n "${CI_PRIMARY_REPOSITORY_PATH}" ]; then
    PROJECT_ROOT="${CI_PRIMARY_REPOSITORY_PATH}"
elif [ -n "${CI_WORKSPACE}" ]; then
    PROJECT_ROOT="${CI_WORKSPACE}"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
fi

echo "Project root: ${PROJECT_ROOT}"

# Create directories that build plugins might need
# This prevents "permission denied" errors when plugins try to create files
echo "Creating build directories..."
mkdir -p "${PROJECT_ROOT}/lich-plus/Resources"
echo "Resources directory ready"

echo "Pre-Xcodebuild: Completed"
