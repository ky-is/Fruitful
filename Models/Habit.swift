import SwiftData
import SwiftUI

enum HabitInterval: Codable, CaseIterable, CustomStringConvertible {
	case day, week, month, year

	var description: String {
		switch self {
		case .day: "daily"
		case .week: "weekly"
		case .month: "monthly"
		case .year: "yearly"
		}
	}
}

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

@Model
final class Habit {
	@Attribute(.unique) var title: String
	var createdAt: Date
	var icon: String
	var interval: HabitInterval
	var goalLabel: String
	var goalCount: Int

	var hexColor: UInt
	var color: CGColor {
		get {
			CGColor(srgbRed: Double((hexColor >> 16) & 0xff) / 255, green: Double((hexColor >> 08) & 0xff) / 255, blue: Double((hexColor >> 00) & 0xff) / 255, alpha: 1)
		}
		set {
			hexColor = newValue.hexColor
		}
	}

	var completedFor: Date
	var completedAt: Date?
	var completedCount: Int
	var completedStreak: Int

	var notifyEnabled: Bool
	var notifyAt: Date

	@Relationship(deleteRule: .cascade, inverse: \HabitEntry.habit)
	var entries: [HabitEntry] = []
	var activeEntry: HabitEntry?

	init(title: String, icon: String = "", interval: HabitInterval = .day, goalLabel: String = "", goalCount: Int = 1, hexColor: UInt? = nil, completedAt: Date? = nil) {
		let date = Date()
		self.title = title
		self.createdAt = date
		self.icon = icon
		self.interval = interval
		self.goalLabel = goalLabel
		self.goalCount = goalCount
		self.hexColor = hexColor ?? .random(in: 99999...999999999)
		self.completedFor = Date()
		self.completedAt = completedAt
		self.completedCount = 0
		self.completedStreak = 0
		self.notifyEnabled = false
		self.notifyAt = Date.distantPast
		self.activeEntry = HabitEntry(habit: self)
	}
}
