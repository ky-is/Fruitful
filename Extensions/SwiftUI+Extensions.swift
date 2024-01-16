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
	static let body = Self.system(.body, design: .rounded)
	static let callout = Self.system(.callout, design: .rounded)
	static let caption = Self.system(.caption, design: .rounded)
	static let headline = Self.system(.headline, design: .rounded)
	static let subheadline = Self.system(.subheadline, design: .rounded)
	static let footnote = Self.system(.footnote, design: .rounded)
	static let title = Self.system(.title, design: .rounded)
	static let title2 = Self.system(.title2, design: .rounded)
	static let title3 = Self.system(.title3, design: .rounded)
}
