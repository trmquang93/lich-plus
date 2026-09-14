#!/bin/sh

# Xcode Cloud Post Xcodebuild Script
# Runs after Xcode build/archive
# Uploads the IPA to App Store Connect via Fastlane

set -e

echo "Submitting: Starting Post Xcodebuild Script..."

# Do not mask archive failures with a secondary "no .ipa" error
if [ "${CI_XCODEBUILD_EXIT_CODE:-0}" != "0" ]; then
    echo "Skipping: xcodebuild failed with exit code ${CI_XCODEBUILD_EXIT_CODE}"
    exit 0
fi

export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

RUBY_PATH="$(brew --prefix ruby@3.3)/bin"
export PATH="${RUBY_PATH}:${PATH}"
export GEM_HOME="${HOME}/.gem"
export PATH="${GEM_HOME}/bin:${PATH}"

if [ "${CI_XCODEBUILD_ACTION}" != "archive" ]; then
    echo "Skipping: Not an archive action (action: ${CI_XCODEBUILD_ACTION})"
    exit 0
fi

if [ "${CI_WORKFLOW}" != "Release" ]; then
    echo "Skipping: Not the Release workflow (workflow: ${CI_WORKFLOW})"
    exit 0
fi

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

if [ -z "${ASC_KEY_ID}" ] || [ -z "${ASC_ISSUER_ID}" ] || [ -z "${ASC_KEY_CONTENT}" ]; then
    echo "Error: Missing required App Store Connect API environment variables"
    exit 1
fi

VERSION_NUMBER=$(resolve_release_version || true)
if [ -n "${VERSION_NUMBER}" ]; then
    echo "Extracted version from $(resolve_release_source): ${VERSION_NUMBER}"
else
    echo "No release tag or release/v* branch, version will be read from Info.plist"
fi

echo ""
echo "==========================================="
echo "Discovering .ipa File"
echo "==========================================="

IPA_PATH=""

if [ -n "${PRODUCT_NAME}" ] && [ -f "${APP_STORE_EXPORT_PATH}/${PRODUCT_NAME}.ipa" ]; then
    IPA_PATH="${APP_STORE_EXPORT_PATH}/${PRODUCT_NAME}.ipa"
elif [ -f "${APP_STORE_EXPORT_PATH}" ]; then
    IPA_PATH="${APP_STORE_EXPORT_PATH}"
else
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

cd "${PROJECT_ROOT}"

if [ ! -f "fastlane/Fastfile" ]; then
    echo "Error: Fastfile not found in fastlane directory"
    exit 1
fi

echo ""
echo "==========================================="
echo "Uploading to App Store Connect"
echo "==========================================="
echo "Ruby: $(ruby --version)"
echo "Build Number: ${BUILD_NUMBER}"
echo "IPA: ${IPA_PATH}"
echo ""

export DEVELOPER_DIR=$(xcode-select -p)
echo "DEVELOPER_DIR set to: ${DEVELOPER_DIR}"

bundle exec fastlane ios xcode_cloud_submit \
    ipa_path:"${IPA_PATH}" \
    version:"${VERSION_NUMBER}"

FASTLANE_EXIT_CODE=$?

echo ""
if [ ${FASTLANE_EXIT_CODE} -eq 0 ]; then
    echo "==========================================="
    echo "Success: Build submitted to App Store!"
    echo "==========================================="
    exit 0
else
    echo "==========================================="
    echo "Error: Fastlane submission failed"
    echo "==========================================="
    echo "Exit code: ${FASTLANE_EXIT_CODE}"
    exit ${FASTLANE_EXIT_CODE}
fi
