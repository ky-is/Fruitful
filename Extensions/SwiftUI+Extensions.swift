import SwiftUI

extension Color {
#if os(macOS)
	static let background = Self(NSColor.windowBackgroundColor)
#else
	static let background = Self(UIColor.systemBackground)
#endif
}

#if !os(macOS)
extension UIColor {
	static let accentColor = UIColor(named: "AccentColor")!
}
#endif

extension Font {
	static let roundedBody = Self.system(.body, design: .rounded)
	static let roundedCallout = Self.system(.callout, design: .rounded)
	static let roundedCaption = Self.system(.caption, design: .rounded)
	static let roundedHeadline = Self.system(.headline, design: .rounded)
	static let roundedSubheadline = Self.system(.subheadline, design: .rounded)
	static let roundedFootnote = Self.system(.footnote, design: .rounded)
	static let roundedTitle = Self.system(.title, design: .rounded)
	static let roundedTitle2 = Self.system(.title2, design: .rounded)
	static let roundedTitle3 = Self.system(.title3, design: .rounded)
}
