#!/bin/sh

# Xcode Cloud Post Clone Script
# Runs after Xcode Cloud clones the repository
# Handles dependencies installation and environment setup

set -e

echo "Building: Starting Post Clone Script..."

export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

# =============================================================================
# FORCE IPv4 FOR ALL NETWORK OPERATIONS (MANDATORY)
# =============================================================================
echo "Configuring global IPv4-only networking..."
cat > "${HOME}/.curlrc" <<'CURLRC'
--ipv4
--retry 5
--retry-delay 5
--retry-max-time 120
--connect-timeout 30
CURLRC
echo "Created ~/.curlrc (IPv4-only, 5 retries, 30s connect timeout)"

# =============================================================================
# XCODE CONFIGURATION
# =============================================================================
echo "Configuring Xcode settings..."
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
echo "Plugin fingerprint validation disabled"
echo ""

# =============================================================================
# PROJECT SETUP
# =============================================================================
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

if [ ! -d "${PROJECT_ROOT}" ]; then
    echo "Error: Project root directory does not exist: ${PROJECT_ROOT}"
    exit 1
fi

cd "${PROJECT_ROOT}"

# =============================================================================
# VERSION MANAGEMENT FROM RELEASE TAG OR BRANCH
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/ci_resolve_version.sh"

echo ""
echo "=========================================="
echo "Version Management"
echo "=========================================="
echo "CI_BRANCH=${CI_BRANCH:-}"
echo "CI_TAG=${CI_TAG:-}"

VERSION=$(resolve_release_version || true)
RELEASE_SOURCE=$(resolve_release_source || true)

if [ -n "${VERSION}" ]; then
    echo "Detected release ${RELEASE_SOURCE}"

    if is_valid_release_version "${VERSION}"; then
        PBXPROJ_PATH="${PROJECT_ROOT}/lich-plus.xcodeproj/project.pbxproj"

        if [ ! -f "${PBXPROJ_PATH}" ]; then
            echo "Error: project.pbxproj not found at ${PBXPROJ_PATH}"
            exit 1
        fi

        echo "Updating MARKETING_VERSION to ${VERSION}"
        sed -i '' "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = ${VERSION};/g" "${PBXPROJ_PATH}"

        UPDATED_VERSION=$(grep -m1 "MARKETING_VERSION" "${PBXPROJ_PATH}" | sed 's/.*= //;s/;.*//;s/^[[:space:]]*//')
        echo "Verified MARKETING_VERSION: ${UPDATED_VERSION}"

        if [ "${UPDATED_VERSION}" != "${VERSION}" ]; then
            echo "Error: Version update verification failed (expected ${VERSION}, got ${UPDATED_VERSION})"
            exit 1
        fi
    else
        echo "Warning: release version '${VERSION}' does not match format (1.2.3)"
        echo "Skipping version update"
    fi
else
    echo "No release tag or release/v* branch found, skipping version update"
fi

echo ""

# =============================================================================
# FIREBASE GoogleService-Info.plist (optional)
# =============================================================================
GOOGLE_PLIST_DEST="${PROJECT_ROOT}/lich-plus/GoogleService-Info.plist"

if [ -f "${GOOGLE_PLIST_DEST}" ]; then
    echo "GoogleService-Info.plist already present"
elif [ -n "${GOOGLESERVICE_INFO_PLIST_BASE64}" ]; then
    echo "${GOOGLESERVICE_INFO_PLIST_BASE64}" | base64 --decode > "${GOOGLE_PLIST_DEST}"
    echo "Copied GoogleService-Info.plist from GOOGLESERVICE_INFO_PLIST_BASE64"
elif [ -n "${GOOGLESERVICE_INFO_PLIST}" ] && [ -f "${GOOGLESERVICE_INFO_PLIST}" ]; then
    cp "${GOOGLESERVICE_INFO_PLIST}" "${GOOGLE_PLIST_DEST}"
    echo "Copied GoogleService-Info.plist from GOOGLESERVICE_INFO_PLIST path"
elif [ -n "${GOOGLESERVICE_INFO_PLIST}" ]; then
    printf '%s\n' "${GOOGLESERVICE_INFO_PLIST}" > "${GOOGLE_PLIST_DEST}"
    echo "Wrote GoogleService-Info.plist from GOOGLESERVICE_INFO_PLIST"
elif [ -f "${PROJECT_ROOT}/ci_scripts/GoogleService-Info.plist" ]; then
    cp "${PROJECT_ROOT}/ci_scripts/GoogleService-Info.plist" "${GOOGLE_PLIST_DEST}"
    echo "Copied GoogleService-Info.plist from ci_scripts/"
else
    echo "GoogleService-Info.plist not provided — Firebase stays inactive; Crashlytics upload will skip"
fi

echo ""

# =============================================================================
# RUBY SETUP VIA HOMEBREW
# =============================================================================
echo "=========================================="
echo "Setting up Ruby via Homebrew"
echo "=========================================="
echo "System Ruby: $(ruby --version)"

brew install ruby@3.3

RUBY_PATH="$(brew --prefix ruby@3.3)/bin"
export PATH="${RUBY_PATH}:${PATH}"
export GEM_HOME="${HOME}/.gem"
export PATH="${GEM_HOME}/bin:${PATH}"

echo "Ruby: $(ruby --version)"

RUBY_CPU="$(ruby -e 'print RbConfig::CONFIG["host_cpu"]')"
echo "Ruby host_cpu=${RUBY_CPU} uname -m=$(uname -m)"
if [ "$(uname -m)" != "${RUBY_CPU}" ]; then
    echo "Host arch != Ruby arch: installing clang shim to force -arch ${RUBY_CPU}"
    CC_SHIM="${HOME}/cc-shim"
    mkdir -p "${CC_SHIM}"
    for tool in cc clang gcc c++ clang++ g++; do
        real="$(command -v "${tool}" 2>/dev/null || echo "/usr/bin/${tool}")"
        cat > "${CC_SHIM}/${tool}" <<EOF
#!/bin/sh
exec "${real}" -arch ${RUBY_CPU} "\$@"
EOF
        chmod +x "${CC_SHIM}/${tool}"
    done
    export PATH="${CC_SHIM}:${PATH}"
fi

# =============================================================================
# BUNDLER DEPENDENCIES
# =============================================================================
echo ""
echo "=========================================="
echo "Installing Ruby Dependencies"
echo "=========================================="

echo "Installing bundler 2.7.2..."
gem install bundler:2.7.2 --no-document
echo "Bundler: $(bundle --version)"

if [ -f "Gemfile" ]; then
    export BUNDLER_FORCE_IPV4=true
    bundle config set --local path 'vendor/bundle'

    MAX_RETRIES=5
    RETRY_COUNT=0
    BUNDLE_SUCCESS=false

    while [ ${RETRY_COUNT} -lt ${MAX_RETRIES} ]; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "bundle install attempt ${RETRY_COUNT}/${MAX_RETRIES}..."

        set +e
        bundle _2.7.2_ install --jobs 3 --retry 3
        BUNDLE_EXIT=$?
        set -e

        if [ ${BUNDLE_EXIT} -eq 0 ]; then
            BUNDLE_SUCCESS=true
            break
        fi

        if [ ${RETRY_COUNT} -lt ${MAX_RETRIES} ]; then
            WAIT_TIME=$((RETRY_COUNT * 15))
            echo "bundle install failed (exit ${BUNDLE_EXIT}), retrying in ${WAIT_TIME}s..."
            sleep ${WAIT_TIME}
        fi
    done

    if [ "${BUNDLE_SUCCESS}" != true ]; then
        echo "Error: bundle install failed after ${MAX_RETRIES} attempts"
        exit 1
    fi

    echo "Bundle installation completed"
else
    echo "Warning: No Gemfile found, skipping bundle install"
fi

echo ""

# =============================================================================
# COCOAPODS DEPENDENCIES
# =============================================================================
echo "=========================================="
echo "Installing CocoaPods"
echo "=========================================="

if [ -f "Podfile" ]; then
    if [ -d "${HOME}/.cocoapods/repos/trunk" ]; then
        echo "Removing existing trunk repo to avoid conflicts..."
        rm -rf "${HOME}/.cocoapods/repos/trunk"
    fi

    export COCOAPODS_DISABLE_STATS=true

    MAX_RETRIES=5
    RETRY_COUNT=0
    POD_SUCCESS=false

    while [ ${RETRY_COUNT} -lt ${MAX_RETRIES} ]; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "pod install attempt ${RETRY_COUNT}/${MAX_RETRIES}..."

        set +e
        bundle exec pod install --repo-update
        POD_EXIT=$?
        set -e

        if [ ${POD_EXIT} -eq 0 ]; then
            POD_SUCCESS=true
            break
        fi

        if [ ${RETRY_COUNT} -lt ${MAX_RETRIES} ]; then
            WAIT_TIME=$((RETRY_COUNT * 15))
            echo "pod install failed (exit ${POD_EXIT}), retrying in ${WAIT_TIME}s..."
            sleep ${WAIT_TIME}
        fi
    done

    if [ "${POD_SUCCESS}" != true ]; then
        echo "Error: CocoaPods installation failed after ${MAX_RETRIES} attempts"
        exit 1
    fi

    PODS_RELEASE_XCCONFIG="$(find "${PROJECT_ROOT}/Pods/Target Support Files" -name "Pods-*.release.xcconfig" 2>/dev/null | head -n 1)"
    if [ -z "${PODS_RELEASE_XCCONFIG}" ]; then
        echo "Error: no Pods release xcconfig found after pod install"
        exit 1
    fi
    echo "Verified CocoaPods xcconfig: ${PODS_RELEASE_XCCONFIG}"
else
    echo "Error: No Podfile found in ${PROJECT_ROOT}"
    exit 1
fi

echo ""
echo "=========================================="
echo "Post Clone Script: Completed successfully!"
echo "=========================================="
exit 0
