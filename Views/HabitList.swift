import SwiftUI
import SwiftData

struct AddHabitButton: View {
	@Binding var selectedHabit: Habit?

	@Environment(\.modelContext) private var modelContext

	var body: some View {
		Button {
			let habit = Habit(title: "")
			selectedHabit = habit
			modelContext.insert(habit)
		} label: {
			Label("New Habit", systemImage: "plus")
				.frame(idealHeight: 44)
		}
	}
}

private struct AddHabitSection: View {
	@Binding var selectedHabit: Habit?

	var body: some View {
		Section {
#if !os(macOS)
			AddHabitButton(selectedHabit: $selectedHabit)
#endif
		}
	}
}

struct HabitGridView: View {
	var groupedHabits: [(label: String, values: [Habit])]
	@Binding var selectedHabit: Habit?

	var body: some View {
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
//							.frame(maxWidth: .infinity, alignment: .leading)
							.foregroundStyle(.secondary)
							.font(.roundedHeadline.smallCaps())
							.padding(.top, 8)
					}
				}
			}
			AddHabitSection(selectedHabit: $selectedHabit)
				.buttonStyle(.bordered)
		}
	}
}

struct HabitListView: View {
	var groupedHabits: [(label: String, values: [Habit])]
	@Binding var selectedHabit: Habit?

	var body: some View {
		List {
			ForEach(groupedHabits, id: \.label) { groupLabel, habits in
				Section {
					ForEach(habits) { habit in
						HabitListItem(habit: habit, asGrid: false, selectedHabit: $selectedHabit)
//							.listRowSeparator(.hidden)
							.frame(minHeight: 56)
					}
				} header: {
					Text(groupLabel)
						.font(.roundedHeadline.smallCaps())
				}
			}
			AddHabitSection(selectedHabit: $selectedHabit)
		}
	}
}

#Preview {
	Group {
		HabitGridView(groupedHabits: [], selectedHabit: .constant(nil))
		HabitListView(groupedHabits: [], selectedHabit: .constant(nil))
	}
}
