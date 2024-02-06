import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.scenePhase) private var scenePhase

	@Query(filter: #Predicate<Habit>{ !$0.archived }) private var habits: [Habit]

	@AppStorage("asGrid") private var asGrid = true

	@State private var selectedHabit: Habit?

	private func updateHabitIntervals() {
		print(#function)
		let now = Date()
		for habit in habits {
			let endedAt = habit.intervalEndAt
			if now > endedAt {
				if habit.completedUntil < endedAt {
					habit.completedStreak = 0
				}
				habit.intervalStartAt = habit.interval.startDate
			}
		}
	}

	private var groupedHabits: [(label: String, values: [Habit])] {
		let now = Date.now
		let upNow = "Up Now"
		let upcoming = "Upcoming"
		let completed = "Completed"
		let groupKeys = [upNow, upcoming, completed]
		let groupedHabits = Dictionary(grouping: habits, by: { habit in
			if habit.completedUntil >= habit.intervalEndAt {
				return completed
			}
			if habit.priority != .low {
				let durationForUpNow = max(TimeInterval.day, habit.interval.duration * Double(habit.goalCount) / 7) // TODO base on how many active entries remain until goal
				let timeLeft = habit.intervalEndAt.timeIntervalSince(now)
				if timeLeft < durationForUpNow {
					return upNow
				}
			}
			return upcoming
		})
		return groupKeys.compactMap {
			guard let values = groupedHabits[$0] else { return nil }
			return (label: $0, values: values)
		}
	}

	var body: some View {
		NavigationStack {
			Group {
				if asGrid {
					HabitGridView(groupedHabits: groupedHabits, selectedHabit: $selectedHabit)
				} else {
					HabitListView(groupedHabits: groupedHabits, selectedHabit: $selectedHabit)
				}
			}
				.navigationTitle("My Habits")
#if os(macOS)
				.listStyle(.plain)
#endif
				.onChange(of: scenePhase) { oldPhase, newPhase in
					if newPhase == .active {
						updateHabitIntervals()
					}
				}
				.toolbar {
					ToolbarItem(placement: .secondaryAction) {
						Button {
							asGrid.toggle()
						} label: {
							Label(asGrid ? "View as list" : "View as grid", systemImage: asGrid ? "checklist.unchecked" : "circle.grid.2x2")
						}
					}
					ToolbarItem(placement: .primaryAction) {
						AddHabitButton(selectedHabit: $selectedHabit)
					}
				}
				.sheet(item: $selectedHabit) { habit in
					NavigationStack {
						HabitEdit(habit: habit)
					}
						.tint(habit.color)
				}
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(PreviewModel.preview.container)
}
