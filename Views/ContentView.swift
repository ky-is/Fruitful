import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.scenePhase) private var scenePhase

	@Query private var habits: [Habit]

	@State private var newHabitPrompt = false
	@State private var newHabitName = ""

	private func updateHabitIntervals() {
		print(#function)
		let now = Date()
		for habit in habits {
			if now > habit.intervalEndAt {
				habit.intervalStartAt = habit.interval.startDate
				habit.intervalEndAt = habit.interval.getEndDate(from: habit.intervalStartAt)
			}
		}
	}

	private var groupedHabits: [(label: String, values: [Habit])] {
		let now = Date()
		let timeRemainingForUpNow: TimeInterval = 24 * 60 * 60 //TODO dynamic
		let groupKeys = ["Up Now", "Upcoming", "Completed"]
		let groupedHabits = Dictionary(grouping: habits, by: { habit in
			if habit.completedUntil >= habit.intervalEndAt {
				return groupKeys[2]
			}
			let timeLeft = habit.intervalEndAt.timeIntervalSince(now)
			if timeLeft < timeRemainingForUpNow {
				return groupKeys[0]
			}
			return groupKeys[1]
		})
		return groupKeys.compactMap {
			guard let values = groupedHabits[$0] else { return nil }
			return (label: $0, values: values)
		}
	}

	var body: some View {
		NavigationSplitView {
			List {
				ForEach(groupedHabits, id: \.label) { groupLabel, habits in
					Section {
						ForEach(habits) { habit in
							HabitListItem(habit: habit)
//								.listRowSeparator(.hidden)
								.frame(minHeight: 56)
						}
					} header: {
						Text(groupLabel)
							.font(.title3)
							.textCase(nil)
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
					ToolbarItem {
						Button {
							newHabitPrompt = true
							newHabitName = ""
						} label: {
							Label("Add Item", systemImage: "plus")
						}
					}
				}
				.alert("Name this Habit", isPresented: $newHabitPrompt) {
					TextField("Name this habit", text: $newHabitName)
#if !os(macOS)
						.textInputAutocapitalization(.words)
#endif
						.submitLabel(.done)
					Button("Create") {
						withAnimation {
							let newItem = Habit(title: newHabitName)
							modelContext.insert(newItem)
						}
					}
					Button("Cancel", role: .cancel) { }
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
