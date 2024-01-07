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
					NavigationLink(value: habit) {
						if habit.title.isEmpty {
							Text("Unlabeled")
								.foregroundStyle(.secondary)
						} else {
							Text(habit.title)
						}
					}
				}
					.onDelete(perform: deleteItems)
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
						.textInputAutocapitalization(.words)
						.submitLabel(.done)
					Button("Create", action: addItem)
					Button("Cancel", role: .cancel) { }
				}
		} detail: {
			Text("Select an item")
		}
	}

	private func addItem() {
		withAnimation {
			let newItem = Habit(title: newHabitName)
			modelContext.insert(newItem)
		}
	}

	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(habits[index])
			}
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(PreviewModel.preview.container)
}
