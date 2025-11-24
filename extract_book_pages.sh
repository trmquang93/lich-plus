#!/bin/bash
#
# Convenience script for extracting Lịch Vạn Niên book pages
# Usage: ./extract_book_pages.sh <pdf_file> <month_number>
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PDF_TO_IMAGES="$SCRIPT_DIR/pdf_to_images.py"

if [ ! -f "$PDF_TO_IMAGES" ]; then
    echo "ERROR: pdf_to_images.py not found"
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 <pdf_file> [month_number]"
    echo ""
    echo "Examples:"
    echo "  $0 lich-van-nien.pdf          # Extract all pages"
    echo "  $0 lich-van-nien.pdf 9        # Extract Month 9 pages (153-157)"
    echo "  $0 lich-van-nien.pdf 10       # Extract Month 10 pages"
    echo ""
    echo "Month to Page Mapping (from Lịch Vạn Niên 2005-2009):"
    echo "  Month 9:  Pages 153-157 (✓ Complete)"
    echo "  Month 10: Pages 158-162"
    echo "  Month 11: Pages 163-167"
    echo "  Month 12: Pages 168-172"
    echo "  Month 1:  Pages TBD"
    echo "  Month 2:  Pages TBD"
    echo "  Month 3:  Pages TBD"
    echo "  Month 4:  Pages TBD"
    echo "  Month 5:  Pages TBD"
    echo "  Month 6:  Pages TBD"
    echo "  Month 7:  Pages TBD"
    echo "  Month 8:  Pages TBD"
    exit 1
fi

PDF_FILE="$1"
MONTH="${2:-all}"

if [ ! -f "$PDF_FILE" ]; then
    echo "ERROR: PDF file not found: $PDF_FILE"
    exit 1
fi

# Define page ranges for each month
# Based on book structure: each month has ~5 pages (60 Can-Chi / 12 per page)
case "$MONTH" in
    9)
        PAGES="153-157"
        OUTPUT_DIR="./book_images/month_09"
        echo "Extracting Month 9 (Tháng 9) - Pages 153-157"
        ;;
    10)
        PAGES="158-162"
        OUTPUT_DIR="./book_images/month_10"
        echo "Extracting Month 10 (Tháng 10) - Pages 158-162"
        ;;
    11)
        PAGES="163-167"
        OUTPUT_DIR="./book_images/month_11"
        echo "Extracting Month 11 (Tháng 11) - Pages 163-167"
        ;;
    12)
        PAGES="168-172"
        OUTPUT_DIR="./book_images/month_12"
        echo "Extracting Month 12 (Tháng 12) - Pages 168-172"
        ;;
    all)
        PAGES=""
        OUTPUT_DIR="./book_images/all_pages"
        echo "Extracting all pages"
        ;;
    *)
        echo "ERROR: Invalid month number: $MONTH"
        echo "Supported months: 9, 10, 11, 12, or 'all'"
        exit 1
        ;;
esac

# Run extraction
if [ -z "$PAGES" ]; then
    python3 "$PDF_TO_IMAGES" "$PDF_FILE" --output "$OUTPUT_DIR" --dpi 200
else
    python3 "$PDF_TO_IMAGES" "$PDF_FILE" --pages "$PAGES" --output "$OUTPUT_DIR" --dpi 200
fi

echo ""
echo "✓ Extraction complete!"
echo "Images saved to: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Open the images to verify quality"
echo "  2. Use images to extract star data for the month"
echo "  3. Update corresponding MonthXStarData.swift file"
