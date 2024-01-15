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
		self._activeEntries = Query(filter: #Predicate { entry in entry.habit?.persistentModelID == id && entry.timestamp > minimum })
	}

	var body: some View {
		Button {
			withAnimation {
				let newCount = activeEntries.count + 1
				let entry = HabitEntry(habit: habit)
				modelContext.insert(entry)
				habit.updateCompleted(newCount: newCount)
			}
		} label: {
			HStack {
				Image(systemName: !habit.icon.isEmpty ? habit.icon : "diamond")
					.imageScale(.large)
					.font(.system(size: 24))
					.frame(width: 44)
					.foregroundStyle(habit.color)
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
			.buttonStyle(.plain)
			.tint(habit.color)
			.swipeActions(edge: .trailing) {
				NavigationLink(destination: HabitEdit(habit: habit)) {
					Label("Edit", systemImage: "pencil")
				}
					.tint(.accentColor)
				if habit.completedUntil < .now {
					Button(role: .destructive) {
						habit.completedUntil = habit.intervalEndAt //TODO confirmation
					} label: {
						Label("Snooze", systemImage: "moon.zzz") // zzz
					}
						.tint(.blue)
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
