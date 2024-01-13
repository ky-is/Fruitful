import SwiftUI
import SwiftData

struct HabitListItem: View {
	let habit: Habit

	@Query private var activeEntries: [HabitEntry]

	@Environment(\.modelContext) private var modelContext

	init(habit: Habit) {
		self.habit = habit
		let minimum = habit.intervalStartAt
		let id = habit.persistentModelID
		self._activeEntries = Query(filter: #Predicate { entry in entry.habit.persistentModelID == id && entry.timestamp > minimum })
	}

	private func onHabit(habit: Habit) {
		withAnimation {
			let newCount = activeEntries.count + 1
			let entry = HabitEntry(habit: habit)
			modelContext.insert(entry)
			habit.updateCompleted(newCount: newCount)
		}
	}

	var body: some View {
		Button {
			onHabit(habit: habit)
		} label: {
			HStack(spacing: 16) {
				Image(systemName: !habit.icon.isEmpty ? habit.icon : "diamond")
					.resizable()
					.frame(width: 32, height: 32)
					.foregroundStyle(Color(cgColor: habit.color))
				VStack(alignment: .leading) {
					if habit.title.isEmpty {
						Text("Unlabeled")
							.foregroundStyle(.secondary)
					} else {
						Text(habit.title)
					}
					HStack {
						if habit.goalCount > 1 {
							Text(activeEntries.count, format: .number)
								.fontWeight(.medium)
							+
							Text(" / ")
							+
							Text(habit.goalCount, format: .number)
								.fontWeight(.medium)
							+
							Text(" " + habit.interval.description)
						} else {
							Text(habit.interval.description)
						}
					}
					.font(.callout)
					.foregroundColor(.secondary)
				}
				Spacer()
				ProgressCircle(habit: habit, count: activeEntries.count, size: 24)
					.fixedSize(horizontal: true, vertical: false)
			}
		}
			.tint(Color(cgColor: habit.color))
			.swipeActions(edge: .trailing) {
				NavigationLink(destination: HabitEdit(habit: habit)) {
					Text("Edit")
				}
					.tint(.accentColor)
				Button("Delete", role: .destructive) {
					modelContext.delete(habit)
					habit.updateCompleted(newCount: activeEntries.count - 1)
				}
			}
	}
}

#Preview {
	NavigationStack {
		List {
			HabitListItem(habit: PreviewModel.preview.habit)
		}
	}
}
