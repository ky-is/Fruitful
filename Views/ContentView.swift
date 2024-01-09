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
		_activeHabitEntries = Query(filter: #Predicate { habitEntry in
			habitEntry.endsAt > now
		})
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

	var body: some View {
		let groupedHabits = Dictionary(grouping: habits) { habit in
			habit.activeEntry == nil || habit.completedFor < habit.activeEntry!.endsAt ? "In Progress" : "Completed"
		}
		let a = groupedHabits.sorted { $0.key > $1.key }
		NavigationSplitView {
			List {
				ForEach(a, id: \.key) { groupLabel, habits in
					Section {
						ForEach(habits) { habit in
							Button {
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
							} label: {
								HabitListItem(habit: habit)
							}
								.frame(minHeight: 64)
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
//				.listStyle(.grouped)
				.onChange(of: scenePhase, { oldPhase, newPhase in
					if newPhase == .active {
						updateActiveHabitEntries()
					}
				})
				.navigationDestination(for: Habit.self) { habit in
					HabitEdit(habit: habit)
				}
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 180, ideal: 200)
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
