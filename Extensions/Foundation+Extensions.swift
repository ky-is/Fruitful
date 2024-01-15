import CoreGraphics
import Foundation

extension CGColor {
	var hexColor: UInt {
		let r = components?[0] ?? 0
		let g = components?[1] ?? 0
		let b = components?[2] ?? 0
		let red = UInt(r * 255) << 16
		let green = UInt(g * 255) << 08
		let blue = UInt(b * 255)
		return red | green | blue
	}
}

extension TimeInterval {
	static let second: Self = 1
	static let minute = .second * 60
	static let hour = .minute * 60
	static let day = .hour * 24
	static let week = .day * 7
}
