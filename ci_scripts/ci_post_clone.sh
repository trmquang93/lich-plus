#!/bin/sh

# Xcode Cloud Post Clone Script
# Runs after Xcode Cloud clones the repository
# Handles dependencies installation and environment setup

set -e

echo "Building: Starting Post Clone Script..."

# =============================================================================
# XCODE CONFIGURATION
# =============================================================================

echo "Configuring Xcode settings..."

# Skip Swift Package Manager plugin fingerprint validation
# Required for build tool plugins to work in Xcode Cloud
echo "Disabling Swift Package Manager plugin fingerprint validation..."
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
echo "Plugin fingerprint validation disabled"

echo ""

# =============================================================================
# PROJECT SETUP
# =============================================================================

# Detect project root with multiple fallbacks for different CI environments
if [ -n "${CI_PRIMARY_REPOSITORY_PATH}" ]; then
    PROJECT_ROOT="${CI_PRIMARY_REPOSITORY_PATH}"
    echo "Detected project root from CI_PRIMARY_REPOSITORY_PATH"
elif [ -n "${CI_WORKSPACE}" ]; then
    PROJECT_ROOT="${CI_WORKSPACE}"
    echo "Detected project root from CI_WORKSPACE"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
    echo "Auto-detected project root from script location"
fi

echo "Project root: ${PROJECT_ROOT}"

# Validate project root exists
if [ ! -d "${PROJECT_ROOT}" ]; then
    echo "Error: Project root directory does not exist: ${PROJECT_ROOT}"
    exit 1
fi

cd "${PROJECT_ROOT}"

# =============================================================================
# VERSION MANAGEMENT FROM GIT TAG
# =============================================================================

if [ -n "${CI_TAG}" ]; then
    echo "Detected CI_TAG: ${CI_TAG}"

    # Extract version from tag (v1.2.3 -> 1.2.3)
    VERSION=${CI_TAG#v}

    # Validate version format (X.Y.Z or X.Y)
    if echo "${VERSION}" | grep -qE '^[0-9]+\.[0-9]+(\.[0-9]+)?$'; then
        echo "Updating marketing version to: ${VERSION}"

        # Use agvtool to update version (works with Xcode project settings)
        cd "${PROJECT_ROOT}"
        agvtool new-marketing-version "${VERSION}"

        if [ $? -eq 0 ]; then
            echo "Marketing version updated to ${VERSION}"
            # Verify the change
            UPDATED_VERSION=$(agvtool what-marketing-version -terse1 2>/dev/null || echo "${VERSION}")
            echo "Verified marketing version: ${UPDATED_VERSION}"
        else
            echo "Warning: agvtool failed, version may not be updated"
            # Don't fail the build - Xcode Cloud may handle versioning differently
        fi
    else
        echo "Warning: CI_TAG '${CI_TAG}' does not match version format (v1.2.3)"
        echo "Skipping version update"
    fi
else
    echo "No CI_TAG found, skipping version update"
fi

echo ""

# =============================================================================
# RBENV RUBY VERSION MANAGEMENT
# =============================================================================

echo "Setting up rbenv for Ruby version management..."

# Install rbenv and ruby-build via Homebrew
if ! command -v rbenv &> /dev/null; then
    echo "Installing rbenv and ruby-build..."
    brew install rbenv ruby-build
else
    echo "rbenv already installed"
fi

# Initialize rbenv for this shell session
eval "$(rbenv init - bash)"

# Read Ruby version from .ruby-version file
if [ -f ".ruby-version" ]; then
    RUBY_VERSION=$(cat .ruby-version | tr -d '[:space:]')
    echo "Required Ruby version from .ruby-version: ${RUBY_VERSION}"
else
    RUBY_VERSION="3.2.2"
    echo "No .ruby-version found, using default: ${RUBY_VERSION}"
fi

# Install the required Ruby version if not already installed
if ! rbenv versions | grep -q "${RUBY_VERSION}"; then
    echo "Installing Ruby ${RUBY_VERSION} via rbenv..."
    rbenv install "${RUBY_VERSION}"
else
    echo "Ruby ${RUBY_VERSION} already installed"
fi

# Set the Ruby version for this project
rbenv local "${RUBY_VERSION}"
rbenv rehash

# Verify Ruby version
ACTUAL_RUBY=$(ruby --version)
echo "Active Ruby: ${ACTUAL_RUBY}"

# Install bundler for this Ruby version
echo "Installing bundler..."
gem install bundler --no-document
rbenv rehash

echo "rbenv setup complete with Ruby ${RUBY_VERSION}"
echo ""

# =============================================================================
# BUNDLER DEPENDENCIES
# =============================================================================

echo "Installing Ruby dependencies via Bundler..."

if [ -f "Gemfile" ]; then
    echo "Current Ruby: $(ruby --version)"
    echo "Current bundler: $(bundle --version)"

    if [ -f "Gemfile.lock" ]; then
        echo "Using Gemfile.lock for consistent gem versions"
    else
        echo "Warning: No Gemfile.lock found - bundler will resolve dependencies"
    fi

    # Configure bundler and install
    bundle config set --local path 'vendor/bundle'
    bundle install

    if [ $? -eq 0 ]; then
        echo "Bundle installation completed successfully"
    else
        echo "Error: Bundle installation failed"
        exit 1
    fi
else
    echo "Warning: No Gemfile found, skipping bundle install"
fi

echo ""

# =============================================================================
# COCOAPODS DEPENDENCIES
# =============================================================================

echo "Installing CocoaPods dependencies..."

if [ -f "Podfile" ]; then
    echo "Running: bundle exec pod install --repo-update"

    bundle exec pod install --repo-update

    POD_EXIT_CODE=$?

    if [ ${POD_EXIT_CODE} -eq 0 ]; then
        echo "CocoaPods installation completed successfully"
    else
        echo "Error: CocoaPods installation failed with exit code ${POD_EXIT_CODE}"
        exit ${POD_EXIT_CODE}
    fi
else
    echo "Error: No Podfile found in ${PROJECT_ROOT}"
    exit 1
fi

echo ""
echo "=========================================="
echo "Post Clone Script: Completed successfully!"
echo "=========================================="
exit 0
