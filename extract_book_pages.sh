#!/bin/bash
#
# Convenience script for extracting Lich Van Nien book pages
# Usage: ./extract_book_pages.sh <pdf_file> [month_number|section]
#
# Page mappings based on official book index (pages 188-191)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PDF_TO_IMAGES="$SCRIPT_DIR/pdf_to_images.py"

if [ ! -f "$PDF_TO_IMAGES" ]; then
    echo "ERROR: pdf_to_images.py not found"
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 <pdf_file> [month_number|section]"
    echo ""
    echo "Examples:"
    echo "  $0 lich-van-nien.pdf          # Extract all pages"
    echo "  $0 lich-van-nien.pdf 1        # Extract Month 1 (Thang Gieng) pages"
    echo "  $0 lich-van-nien.pdf 9        # Extract Month 9 pages"
    echo "  $0 lich-van-nien.pdf hoangdao # Extract Hoang Dao reference pages"
    echo "  $0 lich-van-nien.pdf 12truc   # Extract 12 Truc reference pages"
    echo ""
    echo "Month to Page Mapping (from official book index, pages 188-191):"
    echo "  Month 1 (Gieng):  Pages 104-109 (6 pages)"
    echo "  Month 2:          Pages 110-115 (6 pages)"
    echo "  Month 3:          Pages 116-121 (6 pages)"
    echo "  Month 4:          Pages 122-127 (6 pages)"
    echo "  Month 5:          Pages 128-133 (6 pages)"
    echo "  Month 6:          Pages 134-139 (6 pages)"
    echo "  Month 7:          Pages 140-145 (6 pages)"
    echo "  Month 8:          Pages 146-151 (6 pages)"
    echo "  Month 9:          Pages 152-157 (6 pages)"
    echo "  Month 10:         Pages 158-163 (6 pages)"
    echo "  Month 11:         Pages 164-169 (6 pages)"
    echo "  Month 12 (Chap):  Pages 170-175 (6 pages)"
    echo ""
    echo "Special sections:"
    echo "  intro     - Introduction (pages 3-16)"
    echo "  12truc    - 12 Truc system (pages 48-49)"
    echo "  hoangdao  - Hoang Dao / Hac Dao (pages 50-52)"
    echo "  stars     - Star quality tables (pages 77-91)"
    echo "  goodstars - Good stars by month (pages 60-63)"
    echo "  badstars  - Bad stars by month (pages 64-67)"
    echo "  index     - Book index (pages 188-191)"
    exit 1
fi

PDF_FILE="$1"
SECTION="${2:-all}"

if [ ! -f "$PDF_FILE" ]; then
    echo "ERROR: PDF file not found: $PDF_FILE"
    exit 1
fi

# Define page ranges based on official book index
case "$SECTION" in
    1)
        PAGES="104-109"
        OUTPUT_DIR="./book/extract/month_01"
        echo "Extracting Month 1 (Thang Gieng) - Pages 104-109"
        ;;
    2)
        PAGES="110-115"
        OUTPUT_DIR="./book/extract/month_02"
        echo "Extracting Month 2 - Pages 110-115"
        ;;
    3)
        PAGES="116-121"
        OUTPUT_DIR="./book/extract/month_03"
        echo "Extracting Month 3 - Pages 116-121"
        ;;
    4)
        PAGES="122-127"
        OUTPUT_DIR="./book/extract/month_04"
        echo "Extracting Month 4 - Pages 122-127"
        ;;
    5)
        PAGES="128-133"
        OUTPUT_DIR="./book/extract/month_05"
        echo "Extracting Month 5 - Pages 128-133"
        ;;
    6)
        PAGES="134-139"
        OUTPUT_DIR="./book/extract/month_06"
        echo "Extracting Month 6 - Pages 134-139"
        ;;
    7)
        PAGES="140-145"
        OUTPUT_DIR="./book/extract/month_07"
        echo "Extracting Month 7 - Pages 140-145"
        ;;
    8)
        PAGES="146-151"
        OUTPUT_DIR="./book/extract/month_08"
        echo "Extracting Month 8 - Pages 146-151"
        ;;
    9)
        PAGES="152-157"
        OUTPUT_DIR="./book/extract/month_09"
        echo "Extracting Month 9 - Pages 152-157"
        ;;
    10)
        PAGES="158-163"
        OUTPUT_DIR="./book/extract/month_10"
        echo "Extracting Month 10 - Pages 158-163"
        ;;
    11)
        PAGES="164-169"
        OUTPUT_DIR="./book/extract/month_11"
        echo "Extracting Month 11 - Pages 164-169"
        ;;
    12)
        PAGES="170-175"
        OUTPUT_DIR="./book/extract/month_12"
        echo "Extracting Month 12 (Thang Chap) - Pages 170-175"
        ;;
    intro)
        PAGES="3-16"
        OUTPUT_DIR="./book/extract/intro"
        echo "Extracting Introduction - Pages 3-16"
        ;;
    12truc)
        PAGES="48-49"
        OUTPUT_DIR="./book/extract/12truc"
        echo "Extracting 12 Truc System - Pages 48-49"
        ;;
    hoangdao)
        PAGES="50-52"
        OUTPUT_DIR="./book/extract/hoangdao"
        echo "Extracting Hoang Dao / Hac Dao - Pages 50-52"
        ;;
    stars)
        PAGES="77-91"
        OUTPUT_DIR="./book/extract/star_quality"
        echo "Extracting Star Quality Tables - Pages 77-91"
        ;;
    goodstars)
        PAGES="60-63"
        OUTPUT_DIR="./book/extract/good_stars"
        echo "Extracting Good Stars by Month - Pages 60-63"
        ;;
    badstars)
        PAGES="64-67"
        OUTPUT_DIR="./book/extract/bad_stars"
        echo "Extracting Bad Stars by Month - Pages 64-67"
        ;;
    index)
        PAGES="188-191"
        OUTPUT_DIR="./book/extract/index"
        echo "Extracting Book Index - Pages 188-191"
        ;;
    all)
        PAGES=""
        OUTPUT_DIR="./book/pages"
        echo "Extracting all pages to ./book/pages/"
        ;;
    *)
        echo "ERROR: Invalid section: $SECTION"
        echo "Use a month number (1-12) or a section name (intro, 12truc, hoangdao, stars, goodstars, badstars, index, all)"
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
echo "Extraction complete!"
echo "Images saved to: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Open the images to verify content"
echo "  2. Use images to extract/verify star data"
echo "  3. Update corresponding MonthXStarData.swift file if needed"
