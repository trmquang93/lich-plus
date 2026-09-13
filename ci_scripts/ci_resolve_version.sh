#!/bin/sh
# Resolves release version from Xcode Cloud environment variables.
# Supports CI_TAG (v1.2.3) and CI_BRANCH (release/v1.2.3).

resolve_release_version() {
    if [ -n "${CI_TAG}" ]; then
        echo "${CI_TAG#v}"
        return 0
    fi

    if [ -n "${CI_BRANCH}" ]; then
        case "${CI_BRANCH}" in
            release/v*)
                echo "${CI_BRANCH#release/v}"
                return 0
                ;;
        esac
    fi

    return 1
}

resolve_release_source() {
    if [ -n "${CI_TAG}" ]; then
        echo "tag ${CI_TAG}"
        return 0
    fi

    if [ -n "${CI_BRANCH}" ]; then
        case "${CI_BRANCH}" in
            release/v*)
                echo "branch ${CI_BRANCH}"
                return 0
                ;;
        esac
    fi

    return 1
}

is_valid_release_version() {
    echo "$1" | grep -qE '^[0-9]+\.[0-9]+(\.[0-9]+)?$'
}
