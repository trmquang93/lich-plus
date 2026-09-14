#!/bin/sh
# Resolves release version from Xcode Cloud environment variables.
# Supports CI_TAG (v1.2.3) and CI_BRANCH (release/v1.2.3).

normalize_ci_branch() {
    branch="${1:-}"
    branch="${branch#refs/heads/}"
    branch="${branch#origin/}"
    printf '%s' "${branch}"
}

resolve_release_version() {
    if [ -n "${CI_TAG}" ]; then
        echo "${CI_TAG#v}"
        return 0
    fi

    if [ -n "${CI_BRANCH}" ]; then
        BRANCH="$(normalize_ci_branch "${CI_BRANCH}")"
        case "${BRANCH}" in
            release/v*)
                echo "${BRANCH#release/v}"
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
        BRANCH="$(normalize_ci_branch "${CI_BRANCH}")"
        case "${BRANCH}" in
            release/v*)
                echo "branch ${BRANCH}"
                return 0
                ;;
        esac
    fi

    return 1
}

is_valid_release_version() {
    echo "$1" | grep -qE '^[0-9]+\.[0-9]+(\.[0-9]+)?$'
}
