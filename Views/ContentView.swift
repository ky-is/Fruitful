import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.scenePhase) private var scenePhase

	@Query(filter: #Predicate<Habit>{ !$0.archived }) private var habits: [Habit]

	@AppStorage("asGrid") private var asGrid = true

	@State private var selectedHabit: Habit?

	private func updateHabitIntervals() {
		print(#function)
		let now = Date()
		for habit in habits {
			if now > habit.intervalEndAt {
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

	private var addHabitButton: some View {
		Button {
			let habit = Habit(title: "")
			selectedHabit = habit
			modelContext.insert(habit)
		} label: {
			Label("New Habit", systemImage: "plus")
				.frame(idealHeight: 44)
		}
	}
	private var addHabitSection: some View {
		Section {
#if !os(macOS)
			addHabitButton
#endif
		}
	}

	var body: some View {
		NavigationStack {
			Group {
				if asGrid {
					ScrollView {
						LazyVGrid(columns: [.init(.adaptive(minimum: 96, maximum: 128))]) {
							ForEach(groupedHabits, id: \.label) { groupLabel, habits in
								Section {
									ForEach(habits) { habit in
										HabitListItem(habit: habit, asGrid: true, selectedHabit: $selectedHabit)
											.padding(.horizontal, 4)
											.padding(.bottom, 16)
									}
								} header: {
									Text(groupLabel)
//										.frame(maxWidth: .infinity, alignment: .leading)
										.foregroundStyle(.secondary)
										.font(.roundedHeadline.smallCaps())
								}
							}
						}
							.padding(.bottom)
						addHabitSection
							.buttonStyle(.bordered)
					}
				} else {
					List {
						ForEach(groupedHabits, id: \.label) { groupLabel, habits in
							Section {
								ForEach(habits) { habit in
									HabitListItem(habit: habit, asGrid: false, selectedHabit: $selectedHabit)
//										.listRowSeparator(.hidden)
										.frame(minHeight: 56)
								}
							} header: {
								Text(groupLabel)
									.font(.roundedHeadline.smallCaps())
							}
						}
						addHabitSection
					}
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
						addHabitButton
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
