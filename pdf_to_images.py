#!/usr/bin/env python3
"""
PDF to JPEG Image Extractor
Extracts pages from PDF as high-quality JPEG images for OCR and manual reading.

Usage:
    python3 pdf_to_images.py <pdf_file> [options]

Examples:
    # Extract all pages
    python3 pdf_to_images.py lich-van-nien.pdf

    # Extract specific pages (page numbers start from 1)
    python3 pdf_to_images.py lich-van-nien.pdf --pages 153-157

    # Extract single page
    python3 pdf_to_images.py lich-van-nien.pdf --pages 153

    # Extract with custom output directory
    python3 pdf_to_images.py lich-van-nien.pdf --output ./book_images

    # Extract with custom DPI (higher = better quality, larger file)
    python3 pdf_to_images.py lich-van-nien.pdf --dpi 300
"""

import os
import sys
import argparse
from pathlib import Path

try:
    import fitz  # PyMuPDF
except ImportError:
    print("ERROR: PyMuPDF library not found.")
    print("Install with: pip3 install PyMuPDF")
    sys.exit(1)


def parse_page_range(page_str):
    """
    Parse page range string into list of page numbers.

    Examples:
        "5" -> [5]
        "1-5" -> [1, 2, 3, 4, 5]
        "1,3,5" -> [1, 3, 5]
        "1-3,7,10-12" -> [1, 2, 3, 7, 10, 11, 12]

    Args:
        page_str: String representing page numbers/ranges

    Returns:
        List of page numbers (1-indexed)
    """
    pages = set()

    for part in page_str.split(','):
        part = part.strip()
        if '-' in part:
            # Range: "1-5"
            start, end = part.split('-')
            pages.update(range(int(start), int(end) + 1))
        else:
            # Single page: "5"
            pages.add(int(part))

    return sorted(list(pages))


def extract_pdf_pages(pdf_path, output_dir, pages=None, dpi=200, quality=95):
    """
    Extract PDF pages as JPEG images.

    Args:
        pdf_path: Path to PDF file
        output_dir: Directory to save images
        pages: List of page numbers to extract (1-indexed), or None for all pages
        dpi: Resolution in dots per inch (default: 200)
        quality: JPEG quality 1-100 (default: 95)

    Returns:
        List of created image file paths
    """
    # Open PDF
    pdf_path = Path(pdf_path)
    if not pdf_path.exists():
        raise FileNotFoundError(f"PDF file not found: {pdf_path}")

    print(f"Opening PDF: {pdf_path}")
    doc = fitz.open(pdf_path)
    total_pages = len(doc)
    print(f"Total pages in PDF: {total_pages}")

    # Determine which pages to extract
    if pages is None:
        pages_to_extract = range(1, total_pages + 1)
        print(f"Extracting all pages (1-{total_pages})")
    else:
        pages_to_extract = [p for p in pages if 1 <= p <= total_pages]
        invalid_pages = [p for p in pages if p < 1 or p > total_pages]
        if invalid_pages:
            print(f"WARNING: Skipping invalid pages: {invalid_pages}")
        print(f"Extracting {len(pages_to_extract)} pages: {pages_to_extract}")

    # Create output directory
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"Output directory: {output_dir}")

    # Calculate zoom factor from DPI (72 DPI is default PDF resolution)
    zoom = dpi / 72.0
    mat = fitz.Matrix(zoom, zoom)

    # Extract pages
    created_files = []
    for page_num in pages_to_extract:
        # PyMuPDF uses 0-indexed pages internally
        page_index = page_num - 1

        try:
            print(f"Extracting page {page_num}/{total_pages}...", end=" ")

            # Load page
            page = doc.load_page(page_index)

            # Render page to pixmap (image)
            pix = page.get_pixmap(matrix=mat)

            # Save as JPEG
            output_file = output_dir / f"page_{page_num:04d}.jpg"
            pix.save(str(output_file), "jpeg", jpg_quality=quality)

            file_size_kb = output_file.stat().st_size / 1024
            print(f"✓ ({pix.width}x{pix.height}px, {file_size_kb:.1f}KB)")

            created_files.append(output_file)

        except Exception as e:
            print(f"✗ ERROR: {e}")

    doc.close()

    print(f"\n✓ Successfully extracted {len(created_files)} pages to: {output_dir}")
    return created_files


def main():
    parser = argparse.ArgumentParser(
        description="Extract PDF pages as JPEG images",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Extract all pages
  python3 pdf_to_images.py book.pdf

  # Extract pages 153-157 (for Month 9 star data)
  python3 pdf_to_images.py book.pdf --pages 153-157

  # Extract multiple ranges
  python3 pdf_to_images.py book.pdf --pages 1-10,50-60,100

  # High quality extraction (300 DPI)
  python3 pdf_to_images.py book.pdf --pages 153-157 --dpi 300
        """
    )

    parser.add_argument(
        "pdf_file",
        help="Path to PDF file"
    )

    parser.add_argument(
        "--pages", "-p",
        help="Page numbers to extract (e.g., '1-5', '1,3,5', '1-3,7-9'). Default: all pages",
        default=None
    )

    parser.add_argument(
        "--output", "-o",
        help="Output directory for images. Default: './pdf_images'",
        default="./pdf_images"
    )

    parser.add_argument(
        "--dpi",
        help="Image resolution in DPI. Default: 200. Higher = better quality but larger files",
        type=int,
        default=200
    )

    parser.add_argument(
        "--quality", "-q",
        help="JPEG quality 1-100. Default: 95",
        type=int,
        default=95,
        choices=range(1, 101)
    )

    args = parser.parse_args()

    # Parse page ranges if specified
    pages = None
    if args.pages:
        try:
            pages = parse_page_range(args.pages)
        except Exception as e:
            print(f"ERROR: Invalid page range: {args.pages}")
            print(f"Error: {e}")
            sys.exit(1)

    # Extract pages
    try:
        extract_pdf_pages(
            pdf_path=args.pdf_file,
            output_dir=args.output,
            pages=pages,
            dpi=args.dpi,
            quality=args.quality
        )
    except Exception as e:
        print(f"\nERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
