import Foundation
import SwiftData

enum HabitInterval: Codable, CaseIterable, CustomStringConvertible {
	case day, week, month, year

	var description: String {
		switch self {
		case .day: "Daily"
		case .week: "Weekly"
		case .month: "Monthly"
		case .year: "Yearly"
		}
	}
}

@Model
final class Habit {
	var title: String
	var createdAt: Date
	var icon: String
	var interval: HabitInterval
	var goalLabel: String
	var goalCount: Int

	var completedAt: Date?
	var completedCount: Int
	var completedStreak: Int

	var notifyEnabled: Bool
	var notifyAt: Date

	init(title: String) {
		self.title = title
		self.createdAt = Date()
		self.icon = ""
		self.interval = .day
		self.goalLabel = ""
		self.goalCount = 1

		self.completedAt = nil
		self.completedCount = 0
		self.completedStreak = 0

		self.notifyEnabled = false
		self.notifyAt = Date.distantPast
	}
}
