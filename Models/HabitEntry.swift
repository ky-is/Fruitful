import Foundation
import SwiftData

@Model
final class HabitEntry {
	@Relationship
	var habit: Habit?

	var count = 1
	var timestamp = Date.now
	var body = ""

	init(habit: Habit, count: Int = 1, timestamp: Date = .now, body: String = "") {
		self.habit = habit
		self.count = count
		self.timestamp = timestamp
		self.body = body
	}
}
