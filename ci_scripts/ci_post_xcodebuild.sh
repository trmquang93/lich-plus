#!/bin/sh

# Xcode Cloud Post Xcodebuild Script
# Runs after successful Xcode build/archive
# Uploads the IPA to App Store Connect via Fastlane

set -e

echo "Submitting: Starting Post Xcodebuild Script..."

# Only run for archive actions
if [ "${CI_XCODEBUILD_ACTION}" != "archive" ]; then
    echo "Skipping: Not an archive action (action: ${CI_XCODEBUILD_ACTION})"
    exit 0
fi

# Only run for "Release" workflow (optional - remove this check if you want all archives to submit)
if [ "${CI_WORKFLOW}" != "Release" ]; then
    echo "Skipping: Not the Release workflow (workflow: ${CI_WORKFLOW})"
    exit 0
fi

# Do not attempt upload when the archive step failed
if [ -n "${CI_XCODEBUILD_EXIT_CODE}" ] && [ "${CI_XCODEBUILD_EXIT_CODE}" != "0" ]; then
    echo "Skipping: xcodebuild failed with exit code ${CI_XCODEBUILD_EXIT_CODE}"
    exit "${CI_XCODEBUILD_EXIT_CODE}"
fi

# Environment variables set by Xcode Cloud
PROJECT_ROOT="${CI_PRIMARY_REPOSITORY_PATH}"
BUILD_NUMBER="${CI_BUILD_NUMBER}"
GIT_BRANCH="${CI_BRANCH}"
GIT_TAG="${CI_TAG}"
PRODUCT_NAME="${CI_PRODUCT}"
APP_STORE_EXPORT_PATH="${CI_APP_STORE_SIGNED_APP_PATH}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/ci_resolve_version.sh"

echo ""
echo "==========================================="
echo "Build Information"
echo "==========================================="
echo "Project root: ${PROJECT_ROOT}"
echo "Build number: ${BUILD_NUMBER}"
echo "Git branch: ${GIT_BRANCH}"
echo "Git tag: ${GIT_TAG}"
echo "Product name: ${PRODUCT_NAME}"
echo "Export path: ${APP_STORE_EXPORT_PATH}"
echo ""

# Validate required Xcode Cloud environment variables
if [ -z "${PROJECT_ROOT}" ]; then
    echo "Error: CI_PRIMARY_REPOSITORY_PATH not set"
    exit 1
fi

if [ -z "${BUILD_NUMBER}" ]; then
    echo "Error: CI_BUILD_NUMBER not set"
    exit 1
fi

if [ -z "${APP_STORE_EXPORT_PATH}" ]; then
    echo "Error: CI_APP_STORE_SIGNED_APP_PATH not set"
    echo "This usually means the archive action did not produce an App Store signed export"
    exit 1
fi

# Validate App Store Connect API credentials
if [ -z "${ASC_KEY_ID}" ] || [ -z "${ASC_ISSUER_ID}" ] || [ -z "${ASC_KEY_CONTENT}" ]; then
    echo "Error: Missing required App Store Connect API environment variables"
    echo "Required variables:"
    echo "  - ASC_KEY_ID: Your App Store Connect API Key ID"
    echo "  - ASC_ISSUER_ID: Your App Store Connect Issuer ID"
    echo "  - ASC_KEY_CONTENT: Base64-encoded .p8 private key file content"
    echo ""
    echo "Please configure these as secret environment variables in your Xcode Cloud workflow"
    exit 1
fi

# Extract version number from release tag or release/v* branch
VERSION_NUMBER=$(resolve_release_version || true)
if [ -n "${VERSION_NUMBER}" ]; then
    echo "Extracted version from $(resolve_release_source): ${VERSION_NUMBER}"
else
    echo "No release tag or release/v* branch, version will be read from Info.plist"
fi

# Discover the .ipa file produced by Xcode Cloud
echo ""
echo "==========================================="
echo "Discovering .ipa File"
echo "==========================================="

IPA_PATH=""

# Standard Xcode Cloud layout: $CI_APP_STORE_SIGNED_APP_PATH/$CI_PRODUCT.ipa
if [ -n "${PRODUCT_NAME}" ] && [ -f "${APP_STORE_EXPORT_PATH}/${PRODUCT_NAME}.ipa" ]; then
    IPA_PATH="${APP_STORE_EXPORT_PATH}/${PRODUCT_NAME}.ipa"
elif [ -f "${APP_STORE_EXPORT_PATH}" ]; then
    # CI_APP_STORE_SIGNED_APP_PATH may point directly at the .ipa file
    IPA_PATH="${APP_STORE_EXPORT_PATH}"
else
    # Fall back to searching the export directory tree
    IPA_PATH=$(find "${APP_STORE_EXPORT_PATH}" -name "*.ipa" -print -quit 2>/dev/null || true)
fi

if [ -z "${IPA_PATH}" ] || [ ! -f "${IPA_PATH}" ]; then
    echo "Error: No .ipa file found"
    echo ""
    echo "Checked paths:"
    if [ -n "${PRODUCT_NAME}" ]; then
        echo "  - ${APP_STORE_EXPORT_PATH}/${PRODUCT_NAME}.ipa"
    fi
    echo "  - ${APP_STORE_EXPORT_PATH}"
    echo ""
    echo "Contents of export directory:"
    ls -la "${APP_STORE_EXPORT_PATH}" 2>/dev/null || echo "(directory not accessible)"
    exit 1
fi

IPA_FILENAME=$(basename "${IPA_PATH}")
IPA_SIZE=$(ls -lh "${IPA_PATH}" | awk '{print $5}')

echo "Found IPA file: ${IPA_FILENAME} (size: ${IPA_SIZE})"
echo "Full path: ${IPA_PATH}"

# Navigate to project root
cd "${PROJECT_ROOT}"

# =============================================================================
# RBENV INITIALIZATION
# =============================================================================

echo ""
echo "Initializing rbenv for Ruby environment..."

if command -v rbenv &> /dev/null; then
    eval "$(rbenv init - bash)"
    echo "rbenv initialized: $(ruby --version)"
else
    echo "Warning: rbenv not found, using system Ruby: $(ruby --version)"
fi

# Verify Fastfile exists
if [ ! -f "fastlane/Fastfile" ]; then
    echo "Error: Fastfile not found in fastlane directory"
    exit 1
fi

echo ""
echo "==========================================="
echo "Uploading to App Store Connect"
echo "==========================================="
echo "Build Number: ${BUILD_NUMBER}"
echo "IPA: ${IPA_PATH}"
echo ""

# Set DEVELOPER_DIR to help Fastlane find Xcode tools
# xcode-select -p returns the correct path in Xcode Cloud
export DEVELOPER_DIR=$(xcode-select -p)
echo "DEVELOPER_DIR set to: ${DEVELOPER_DIR}"

# Run Fastlane to upload .ipa
bundle exec fastlane ios xcode_cloud_submit \
    ipa_path:"${IPA_PATH}" \
    version:"${VERSION_NUMBER}"

FASTLANE_EXIT_CODE=$?

echo ""
if [ ${FASTLANE_EXIT_CODE} -eq 0 ]; then
    echo "==========================================="
    echo "Success: Build submitted to App Store!"
    echo "==========================================="
    echo "Build ${BUILD_NUMBER} has been uploaded"
    echo "Check App Store Connect for submission status"
    exit 0
else
    echo "==========================================="
    echo "Error: Fastlane submission failed"
    echo "==========================================="
    echo "Exit code: ${FASTLANE_EXIT_CODE}"
    exit ${FASTLANE_EXIT_CODE}
fi
