//
//  VanKhanPDFRenderer.swift
//  lich-plus
//
//  A4 PDF rendering for văn khấn texts via UIGraphicsPDFRenderer.
//  Multi-page output, Vietnamese-diacritic-safe via system fonts.
//

import Foundation
import UIKit

@MainActor
enum VanKhanPDFRenderer {

    // A4 at 72dpi
    private static let pageSize = CGSize(width: 595.2, height: 841.8)
    private static let margin: CGFloat = 50

    /// Renders to a temp file and returns the URL. Returns nil on failure.
    @discardableResult
    static func renderToTempFile(
        title: String,
        subtitle: String?,
        body: String,
        slug: String
    ) -> URL? {
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "van-khan-\(slug)-\(timestamp).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        let format = UIGraphicsPDFRendererFormat()
        let bounds = CGRect(origin: .zero, size: pageSize)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)

        do {
            try renderer.writePDF(to: url) { ctx in
                drawPages(in: ctx, bounds: bounds, title: title, subtitle: subtitle, body: body)
            }
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Drawing

    private static func drawPages(
        in ctx: UIGraphicsPDFRendererContext,
        bounds: CGRect,
        title: String,
        subtitle: String?,
        body: String
    ) {
        let contentRect = bounds.insetBy(dx: margin, dy: margin)

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
            .foregroundColor: UIColor(red: 199/255, green: 37/255, blue: 29/255, alpha: 1.0),
        ]
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.darkGray,
        ]
        let bodyParagraph = NSMutableParagraphStyle()
        bodyParagraph.lineSpacing = 4
        bodyParagraph.paragraphSpacing = 8
        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "NewYork-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black,
            .paragraphStyle: bodyParagraph,
        ]
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.gray,
        ]

        // Build the full body as an NSAttributedString
        let attributedBody = NSAttributedString(string: body, attributes: bodyAttrs)

        // Measure header on first page
        let titleSize = (title as NSString).boundingRect(
            with: CGSize(width: contentRect.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: titleAttrs,
            context: nil
        ).size
        var headerHeight: CGFloat = titleSize.height + 8
        if let s = subtitle {
            let subSize = (s as NSString).boundingRect(
                with: CGSize(width: contentRect.width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                attributes: subtitleAttrs,
                context: nil
            ).size
            headerHeight += subSize.height + 12
        }

        var rangeStart = 0
        var pageIndex = 0
        let totalLength = attributedBody.length

        while rangeStart < totalLength {
            ctx.beginPage()

            var yCursor: CGFloat = contentRect.minY
            if pageIndex == 0 {
                (title as NSString).draw(
                    in: CGRect(x: contentRect.minX, y: yCursor, width: contentRect.width, height: titleSize.height),
                    withAttributes: titleAttrs
                )
                yCursor += titleSize.height + 8
                if let s = subtitle {
                    let subSize = (s as NSString).boundingRect(
                        with: CGSize(width: contentRect.width, height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin],
                        attributes: subtitleAttrs,
                        context: nil
                    ).size
                    (s as NSString).draw(
                        in: CGRect(x: contentRect.minX, y: yCursor, width: contentRect.width, height: subSize.height),
                        withAttributes: subtitleAttrs
                    )
                    yCursor += subSize.height + 12
                }

                // gold rule
                let rule = UIBezierPath()
                rule.move(to: CGPoint(x: contentRect.minX, y: yCursor))
                rule.addLine(to: CGPoint(x: contentRect.maxX, y: yCursor))
                UIColor(red: 212/255, green: 175/255, blue: 55/255, alpha: 1.0).setStroke()
                rule.lineWidth = 0.5
                rule.stroke()
                yCursor += 12
            }

            let availableHeight = contentRect.maxY - yCursor - 24 // leave room for footer
            // Paginate by binary-searching the longest prefix that fits.
            let textRange = NSRange(location: rangeStart, length: totalLength - rangeStart)
            let substring = attributedBody.attributedSubstring(from: textRange)
            let drawRect = CGRect(x: contentRect.minX, y: yCursor, width: contentRect.width, height: availableHeight)

            // Use Core Text style draw via NSStringDrawing — simpler & honors paragraph style
            let drawing = NSMutableAttributedString(attributedString: substring)
            let boundingSize = CGSize(width: drawRect.width, height: drawRect.height)

            // Binary-search the longest prefix that fits
            var lo = 1
            var hi = drawing.length
            var bestFit = 0
            while lo <= hi {
                let mid = (lo + hi) / 2
                let prefix = drawing.attributedSubstring(from: NSRange(location: 0, length: mid))
                let rect = prefix.boundingRect(with: boundingSize, options: [.usesLineFragmentOrigin], context: nil)
                if rect.height <= drawRect.height {
                    bestFit = mid
                    lo = mid + 1
                } else {
                    hi = mid - 1
                }
            }
            let consumed = max(bestFit, 1)

            let pageSlice = drawing.attributedSubstring(from: NSRange(location: 0, length: consumed))
            pageSlice.draw(with: drawRect, options: [.usesLineFragmentOrigin], context: nil)

            rangeStart += consumed

            // Footer
            let footer = "Theo Văn khấn cổ truyền Việt Nam · trang \(pageIndex + 1)"
            let footerSize = (footer as NSString).boundingRect(
                with: CGSize(width: contentRect.width, height: 20),
                options: [.usesLineFragmentOrigin],
                attributes: footerAttrs,
                context: nil
            ).size
            (footer as NSString).draw(
                in: CGRect(x: contentRect.minX, y: contentRect.maxY - footerSize.height, width: contentRect.width, height: footerSize.height),
                withAttributes: footerAttrs
            )

            pageIndex += 1
            if pageIndex > 50 { break } // hard safety cap
        }
    }
}
