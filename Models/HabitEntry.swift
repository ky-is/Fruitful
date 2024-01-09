import Foundation
import SwiftData

@Model
final class HabitEntry {
	var habit: Habit
	var count: Int
	var startedAt: Date
	var completedAt: Date?
	var endsAt: Date

	init(habit: Habit) {
		let now = Date()
		self.startedAt = now
		self.habit = habit
		self.count = 0

		let calendar = Calendar.current
		self.endsAt = switch habit.interval {
//		case .hour:
//			calendar.date(byAdding: .hour, value: 1, to: calendar.date(bySettingHour: calendar.component(.hour, from: startDate), minute: 0, second: 0, of: startDate)!)!
		case .day:
			calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
		case .week:
			calendar.date(byAdding: .weekOfMonth, value: 1, to: calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!)!
		case .month:
			calendar.date(byAdding: .month, value: 1, to: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!)!
		case .year:
			calendar.date(byAdding: .year, value: 1, to: calendar.date(from: calendar.dateComponents([.year], from: now))!)!
		}
	}
}
