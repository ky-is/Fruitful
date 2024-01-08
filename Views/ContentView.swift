import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var habits: [Habit]

	@State private var newHabitPrompt = false
	@State private var newHabitName = ""

	var body: some View {
		NavigationSplitView {
			List {
				ForEach(habits) { habit in
					Button {
						//TODO
					} label: {
						HStack {
							Label {
								if habit.title.isEmpty {
									Text("Unlabeled")
										.foregroundStyle(.secondary)
								} else {
									Text(habit.title)
								}
							} icon: {
								Image(systemName: !habit.icon.isEmpty ? habit.icon : "diamond")
									.foregroundStyle(Color(cgColor: habit.color))
							}
							Spacer()
							ProgressCircle(habit: habit, size: 24)
								.fixedSize(horizontal: true, vertical: false)
						}
					}
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
			}
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
