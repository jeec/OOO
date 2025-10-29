import SwiftUI
import UIKit

struct SpokenTextView: UIViewRepresentable {
    let text: String
    let highlightedRange: Range<String.Index>?
    let wordMatches: [WordMatch]
    @Binding var selectedIndex: Int?
    let onWordTapped: (String, Int) -> Void
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.isUserInteractionEnabled = true
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        label.addGestureRecognizer(tap)
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        let ranges = calculateWordRanges(in: text)
        uiView.attributedText = buildAttributedString(using: ranges)
        let currentWidth = uiView.bounds.width
        if currentWidth > 0 && uiView.preferredMaxLayoutWidth != currentWidth {
            uiView.preferredMaxLayoutWidth = currentWidth
        }
        context.coordinator.text = text
        context.coordinator.wordRanges = ranges
        context.coordinator.onWordTapped = onWordTapped
        context.coordinator.selectedIndex = $selectedIndex
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func buildAttributedString(using ranges: [Range<String.Index>]) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: attributed.length)
        attributed.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)
        attributed.addAttribute(.backgroundColor, value: UIColor.clear, range: fullRange)
        
        for match in wordMatches {
            guard match.index < ranges.count else { continue }
            let nsRange = NSRange(ranges[match.index], in: text)
            let color: UIColor = match.isCorrect ? .label : .systemRed
            attributed.addAttribute(.foregroundColor, value: color, range: nsRange)
        }
        
        if let highlight = highlightedRange {
            let nsRange = NSRange(highlight, in: text)
            attributed.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: nsRange)
            attributed.addAttribute(.backgroundColor, value: UIColor.systemBlue.withAlphaComponent(0.15), range: nsRange)
        }
        
        if let selectedIndex = selectedIndex,
           selectedIndex >= 0,
           selectedIndex < ranges.count {
            let nsRange = NSRange(ranges[selectedIndex], in: text)
            attributed.addAttribute(.foregroundColor, value: UIColor.white, range: nsRange)
            attributed.addAttribute(.backgroundColor, value: UIColor.systemBlue, range: nsRange)
        }
        
        return attributed
    }
    
    final class Coordinator: NSObject {
        var text: String = ""
        var wordRanges: [Range<String.Index>] = []
        var onWordTapped: ((String, Int) -> Void)?
        var selectedIndex: Binding<Int?>?
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let label = gesture.view as? UILabel else { return }
            let location = gesture.location(in: label)
            guard let (index, range) = range(at: location, label: label) else { return }
            selectedIndex?.wrappedValue = index
            let word = String(text[range])
            onWordTapped?(word, index)
        }
        
        private func range(at location: CGPoint, label: UILabel) -> (Int, Range<String.Index>)? {
            guard let attributedText = label.attributedText else { return nil }
            let textStorage = NSTextStorage(attributedString: attributedText)
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            let textContainer = NSTextContainer(size: label.bounds.size)
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = label.numberOfLines
            textContainer.lineBreakMode = label.lineBreakMode
            layoutManager.addTextContainer(textContainer)
            
            let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            guard index < attributedText.length,
                  let swiftRange = Range(NSRange(location: index, length: 0), in: text) else { return nil }
            if let matchIndex = wordRanges.firstIndex(where: { $0.contains(swiftRange.lowerBound) }) {
                return (matchIndex, wordRanges[matchIndex])
            }
            return nil
        }
    }
}

func calculateWordRanges(in text: String) -> [Range<String.Index>] {
    var ranges: [Range<String.Index>] = []
    var searchStart = text.startIndex
    let pattern = try? NSRegularExpression(pattern: "[A-Za-z'’‘]+", options: [])
    let nsString = text as NSString
    let nsRange = NSRange(location: 0, length: nsString.length)
    let matches = pattern?.matches(in: text, options: [], range: nsRange) ?? []
    for match in matches {
        if let range = Range(match.range, in: text), range.lowerBound >= searchStart {
            ranges.append(range)
            searchStart = range.upperBound
        }
    }
    return ranges
}
