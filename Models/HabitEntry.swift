import Foundation
import SwiftData

@Model
final class HabitEntry {
	@Relationship
	var habit: Habit

	var count: Int
	var timestamp: Date
	var body: String

	init(habit: Habit, count: Int = 1, timestamp: Date? = nil, body: String = "") {
		self.habit = habit
		self.count = count
		self.timestamp = timestamp ?? Date()
		self.body = body
	}
}
