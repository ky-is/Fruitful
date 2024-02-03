import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.scenePhase) private var scenePhase

	@Query(filter: #Predicate<Habit>{ !$0.archived }) private var habits: [Habit]

	@AppStorage("asGrid") private var asGrid = true

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
		NavigationLink {
			let habit = Habit(title: "")
			HabitEdit(habit: habit)
				.onAppear {
					modelContext.insert(habit)
				}
				.onDisappear { //TODO never called
					if habit.title.isEmpty {
						withAnimation {
							modelContext.delete(habit)
						}
					}
				}
		} label: {
			Label("New Habit", systemImage: "plus")
				.frame(idealHeight: 44)
		}
	}

	var body: some View {
		NavigationSplitView {
			Group {
				if asGrid {
					ScrollView {
						LazyVGrid(columns: [.init(.adaptive(minimum: 96, maximum: 128))]) {
							ForEach(groupedHabits, id: \.label) { groupLabel, habits in
								Section {
									ForEach(habits) { habit in
										HabitListItem(habit: habit, asGrid: true)
											.padding(.horizontal, 4)
											.padding(.bottom, 16)
									}
								} header: {
									Text(groupLabel)
//										.frame(maxWidth: .infinity, alignment: .leading)
										.foregroundStyle(.secondary)
										.font(.headline.smallCaps())
								}
							}
						}
							.padding(.bottom)
						Section {
							addHabitButton
						}
							.buttonStyle(.bordered)
					}
				} else {
					List {
						ForEach(groupedHabits, id: \.label) { groupLabel, habits in
							Section {
								ForEach(habits) { habit in
									HabitListItem(habit: habit, asGrid: false)
//										.listRowSeparator(.hidden)
										.frame(minHeight: 56)
								}
							} header: {
								Text(groupLabel)
									.font(.headline.smallCaps())
							}
						}
						Section {
							addHabitButton
						}
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
				.navigationDestination(for: Habit.self) { habit in
					HabitEdit(habit: habit)
				}
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 240, ideal: 300)
#endif
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
		} detail: {
			Text("Select an item")
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(PreviewModel.preview.container)
}
