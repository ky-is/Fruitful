import Foundation

extension TimeInterval {
	static let second: Self = 1
	static let minute = .second * 60
	static let hour = .minute * 60
	static let day = .hour * 24
	static let week = .day * 7
}
