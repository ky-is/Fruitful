import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.scenePhase) private var scenePhase

	@Query private var habits: [Habit]
	@Query private var activeHabitEntries: [HabitEntry]

	@State private var newHabitPrompt = false
	@State private var newHabitName = ""

	init() {
		let now = Date()
		_activeHabitEntries = Query(filter: #Predicate { $0.endsAt > now })
	}

	private func updateActiveHabitEntries() {
		print(#function)
		let now = Date()
		for habit in habits {
			if let activeEntry = activeHabitEntries.first(where: { $0.habit == habit }) {
				habit.activeEntry = activeEntry
			}
			let existingEndsAt = habit.activeEntry?.endsAt
			if existingEndsAt == nil || existingEndsAt! < now {
				if let activeEntry = habit.activeEntry, activeEntry.count == 0 {
					modelContext.delete(activeEntry)
				}
				habit.activeEntry = HabitEntry(habit: habit)
			}
		}
	}

	private var groupedHabits: [(label: String, values: [Habit])] {
		let now = Date()
		let timeRemainingForUpNow: TimeInterval = 24 * 60 * 60 //TODO dynamic
		let groupKeys = ["Up Now", "Upcoming", "Completed"]
		let groupedHabits = Dictionary(grouping: habits, by: { habit in
			if habit.activeEntry != nil {
				let endsAt = habit.activeEntry!.endsAt
				if habit.completedFor >= endsAt {
					return groupKeys[2]
				}
				let timeLeft = endsAt.timeIntervalSince(now)
				if timeLeft < timeRemainingForUpNow {
					return groupKeys[0]
				}
			}
			return groupKeys[1]
		})
		return groupKeys.compactMap {
			guard let values = groupedHabits[$0] else { return nil }
			return (label: $0, values: values)
		}
	}

	private func onHabit(habit: Habit) {
		if let activeEntry = habit.activeEntry {
			withAnimation {
				activeEntry.count += 1
				if activeEntry.count >= habit.goalCount && habit.completedFor < activeEntry.endsAt {
					habit.completedFor = activeEntry.endsAt
					habit.completedAt = Date()
					habit.completedCount += 1
					habit.completedStreak += 1 //TODO
				}
			}
		} else {
			print("ERR no active entry for", habit.title)
		}
	}

	var body: some View {
		NavigationSplitView {
			List {
				ForEach(groupedHabits, id: \.label) { groupLabel, habits in
					Section {
						ForEach(habits) { habit in
							Button {
								onHabit(habit: habit)
							} label: {
								HabitListItem(habit: habit)
							}
								.buttonStyle(.plain)
								.listRowSeparator(.hidden)
								.frame(minHeight: 56)
								.tint(Color(cgColor: habit.color))
								.swipeActions(edge: .trailing) {
									NavigationLink(value: habit) {
										Text("Edit")
									}
										.tint(.accentColor)
									Button("Delete", role: .destructive) {
										modelContext.delete(habit)
									}
								}
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
				.onChange(of: scenePhase, { oldPhase, newPhase in
					if newPhase == .active {
						updateActiveHabitEntries()
					}
				})
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
