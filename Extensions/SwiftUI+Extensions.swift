import SwiftUI

extension Color {
	#if os(macOS)
	static let background = Self(NSColor.windowBackgroundColor)
	#else
	static let background = Self(UIColor.systemBackground)
	#endif
}
