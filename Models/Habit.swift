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

	var startDate: Date {
		let calendar = Calendar.current
		let now = Date()
		return switch self {
//		case .hour: calendar.date(bySettingHour: calendar.component(.hour, from: startDate), minute: 0, second: 0, of: startDate)!
		case .day: calendar.startOfDay(for: now)
		case .week: calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
		case .month: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
		case .year: calendar.date(from: calendar.dateComponents([.year], from: now))!
		}
	}

	func getEndDate(from startDate: Date) -> Date {
		let addComponent: Calendar.Component = switch self {
//		case .hour: .hour
		case .day: .day
		case .week: .weekOfMonth
		case .month: .month
		case .year: .year
		}
		return Calendar.current.date(byAdding: addComponent, value: 1, to: startDate)!
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
final class Habit: Comparable {
	@Attribute(.unique) var title: String
	var createdAt: Date
	var icon: String

	var interval: HabitInterval
	var intervalStartAt: Date
	var intervalEndAt: Date

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

	var completedUntil: Date
	var completedAt: Date?
	var completedCount: Int
	var completedStreak: Int

	var notifyEnabled: Bool
	var notifyAt: Date

	@Relationship(deleteRule: .cascade, inverse: \HabitEntry.habit)
	var allEntries: [HabitEntry] = []

	init(title: String, icon: String = "", interval: HabitInterval = .day, goalLabel: String = "", goalCount: Int = 1, hexColor: UInt? = nil, completedAt: Date? = nil) {
		let date = Date()
		self.title = title
		self.createdAt = date
		self.icon = icon

		self.interval = interval
		let startDate = interval.startDate
		self.intervalStartAt = startDate
		self.intervalEndAt = interval.getEndDate(from: startDate)

		self.goalLabel = goalLabel
		self.goalCount = goalCount
		self.hexColor = hexColor ?? .random(in: 999999...999999999)
		self.completedUntil = Date()
		self.completedAt = completedAt
		self.completedCount = 0
		self.completedStreak = 0
		self.notifyEnabled = false
		self.notifyAt = Date.distantPast
	}

	static func < (lhs: Habit, rhs: Habit) -> Bool {
		lhs.title < rhs.title
	}

	func updateCompleted(newCount: Int) {
		if completedUntil < intervalEndAt {
			if newCount >= goalCount {
				completedUntil = intervalEndAt
				completedAt = Date()
				completedCount += 1
				completedStreak += 1 //TODO
			}
		} else if newCount < goalCount {
			completedUntil = Date.distantPast
			completedAt = nil
			completedCount -= 1
			completedStreak -= 1 //TODO
		}
	}
}
