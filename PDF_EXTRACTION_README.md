# PDF Extraction Tools

Tools for extracting pages from "Lịch Vạn Niên 2005-2009" book as JPEG images for star data extraction.

## Quick Start

**Option 1: Extract specific month (easiest)**
```bash
# Extract Month 10 pages (158-162)
./extract_book_pages.sh path/to/lich-van-nien.pdf 10

# Extract Month 11 pages (163-167)
./extract_book_pages.sh path/to/lich-van-nien.pdf 11

# Extract Month 12 pages (168-172)
./extract_book_pages.sh path/to/lich-van-nien.pdf 12
```

**Option 2: Extract custom page ranges**
```bash
# Extract pages 153-157 (Month 9)
./pdf_to_images.py path/to/lich-van-nien.pdf --pages 153-157

# Extract multiple ranges
./pdf_to_images.py path/to/lich-van-nien.pdf --pages 1-10,50-60,100-150

# High quality extraction (300 DPI)
./pdf_to_images.py path/to/lich-van-nien.pdf --pages 153-157 --dpi 300
```

**Option 3: Extract all pages**
```bash
./pdf_to_images.py path/to/lich-van-nien.pdf
```

## Files

### `pdf_to_images.py`
General-purpose PDF to JPEG converter with flexible options.

**Features:**
- Extract specific pages or page ranges
- Configurable DPI (resolution)
- Configurable JPEG quality
- Batch processing
- Clear progress output

**Options:**
- `--pages`, `-p`: Page range (e.g., "1-5", "1,3,5", "1-3,7-9")
- `--output`, `-o`: Output directory (default: "./pdf_images")
- `--dpi`: Image resolution (default: 200, recommended: 200-300)
- `--quality`, `-q`: JPEG quality 1-100 (default: 95)

### `extract_book_pages.sh`
Convenience wrapper for extracting Lịch Vạn Niên book pages by month number.

**Features:**
- Pre-configured page ranges for each month
- Organized output directories (./book_images/month_XX/)
- Simple month-based interface

**Supported months:**
- Month 9: Pages 153-157 (✓ Complete)
- Month 10: Pages 158-162
- Month 11: Pages 163-167
- Month 12: Pages 168-172
- Months 1-8: TBD (need to verify page numbers in book)

## Requirements

**Python 3** with **PyMuPDF** library:
```bash
pip3 install PyMuPDF
```

Check if installed:
```bash
python3 -c "import fitz; print('PyMuPDF installed:', fitz.version)"
```

## Usage Examples

### Extract Next Month (Month 10)
```bash
# Assuming book PDF is in current directory
./extract_book_pages.sh lich-van-nien.pdf 10

# Output: ./book_images/month_10/page_0158.jpg through page_0162.jpg
```

### Extract with High Quality
```bash
# 300 DPI for better text clarity
./pdf_to_images.py lich-van-nien.pdf --pages 158-162 --dpi 300 --output ./month10_hq
```

### Extract Multiple Months at Once
```bash
# Extract months 10, 11, 12
./extract_book_pages.sh lich-van-nien.pdf 10
./extract_book_pages.sh lich-van-nien.pdf 11
./extract_book_pages.sh lich-van-nien.pdf 12
```

## Workflow

1. **Extract pages for target month:**
   ```bash
   ./extract_book_pages.sh book.pdf 10
   ```

2. **Verify image quality:**
   ```bash
   open ./book_images/month_10/
   ```

3. **Use images for data extraction:**
   - Read each page (5 pages per month)
   - Extract Can-Chi combinations and stars
   - Update MonthXStarData.swift file

4. **Test extracted data:**
   ```bash
   ./run-tests.sh --unit
   ```

## Output Structure

```
book_images/
├── month_09/           # Month 9 (✓ Complete)
│   ├── page_0153.jpg
│   ├── page_0154.jpg
│   ├── page_0155.jpg
│   ├── page_0156.jpg
│   └── page_0157.jpg
├── month_10/           # Month 10 (Next)
│   ├── page_0158.jpg
│   ├── page_0159.jpg
│   ├── page_0160.jpg
│   ├── page_0161.jpg
│   └── page_0162.jpg
└── ...
```

## Troubleshooting

**Error: "PyMuPDF library not found"**
```bash
pip3 install PyMuPDF
```

**Error: "PDF file not found"**
- Check the path to your PDF file
- Use absolute path if relative path doesn't work
- Ensure PDF file is readable

**Images are too small/blurry**
```bash
# Increase DPI (try 250 or 300)
./pdf_to_images.py book.pdf --pages 158-162 --dpi 300
```

**Images are too large**
```bash
# Decrease DPI or quality
./pdf_to_images.py book.pdf --pages 158-162 --dpi 150 --quality 85
```

## Page Mapping Reference

| Lunar Month | Pages      | Status      |
|-------------|------------|-------------|
| Month 1     | TBD        | Not started |
| Month 2     | TBD        | Not started |
| Month 3     | TBD        | Not started |
| Month 4     | TBD        | Not started |
| Month 5     | TBD        | Not started |
| Month 6     | TBD        | Not started |
| Month 7     | TBD        | Not started |
| Month 8     | TBD        | Not started |
| **Month 9** | **153-157**| **✓ Complete** |
| Month 10    | 158-162    | Next        |
| Month 11    | 163-167    | Pending     |
| Month 12    | 168-172    | Pending     |

**Note**: Page numbers for Months 1-8 need to be verified in the book's table of contents.

## Tips

1. **Start with default settings** (200 DPI, quality 95) - good balance of quality and file size
2. **Extract one month at a time** - easier to organize and process
3. **Verify images before data extraction** - ensure text is readable
4. **Use high DPI (300)** if OCR is planned in the future
5. **Keep original PDF** - can re-extract if needed

---

**Created**: November 24, 2025
**Purpose**: Extract book pages for Vietnamese astrology star system data
**Goal**: Complete all 12 months (720 Can-Chi combinations) for 100% accuracy
