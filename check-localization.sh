#!/bin/bash

# Script to find missing localizations in Localizable.xcstrings
# Usage: ./check-localization.sh

set -e

STRINGS_FILE="lich-plus/Localizable.xcstrings"
SOURCE_DIR="lich-plus"

if [ ! -f "$STRINGS_FILE" ]; then
    echo "Error: $STRINGS_FILE not found"
    exit 1
fi

# Extract all keys from Localizable.xcstrings
CATALOG_KEYS=$(jq -r '.strings | keys[]' "$STRINGS_FILE" | sort -u)

echo "Found $(echo "$CATALOG_KEYS" | wc -l) keys in Localizable.xcstrings"
echo ""

# Check for missing translations (keys without EN or VI)
echo "=== MISSING TRANSLATIONS (keys without EN or VI) ==="
INCOMPLETE_COUNT=0
while IFS= read -r key; do
    [ -z "$key" ] && continue

    HAS_EN=$(jq -r ".strings[\"$key\"].localizations.en.stringUnit.value" "$STRINGS_FILE" 2>/dev/null)
    HAS_VI=$(jq -r ".strings[\"$key\"].localizations.vi.stringUnit.value" "$STRINGS_FILE" 2>/dev/null)

    MISSING=""
    if [ -z "$HAS_EN" ] || [ "$HAS_EN" = "null" ]; then
        MISSING="EN"
        ((INCOMPLETE_COUNT++))
    fi
    if [ -z "$HAS_VI" ] || [ "$HAS_VI" = "null" ]; then
        if [ -n "$MISSING" ]; then
            MISSING="$MISSING, VI"
        else
            MISSING="VI"
        fi
        ((INCOMPLETE_COUNT++))
    fi

    if [ -n "$MISSING" ]; then
        echo "  ❌ $key (missing: $MISSING)"
    fi
done <<< "$CATALOG_KEYS"

if [ $INCOMPLETE_COUNT -eq 0 ]; then
    echo "  ✅ All keys have both EN and VI translations"
fi
echo ""


# Summary
echo "=== SUMMARY ==="
echo "Missing translations (EN/VI): $INCOMPLETE_COUNT"

if [ $INCOMPLETE_COUNT -gt 0 ]; then
    exit 1
fi
