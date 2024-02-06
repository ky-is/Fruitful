import SwiftUI
import SwiftData

struct HabitListItem: View {
	let habit: Habit
	let asGrid: Bool
	@Binding var selectedHabit: Habit?

	@Query private var activeEntries: [HabitEntry]

	@Environment(\.modelContext) private var modelContext

	init(habit: Habit, asGrid: Bool, selectedHabit: Binding<Habit?>) {
		self.habit = habit
		self.asGrid = asGrid
		self._selectedHabit = selectedHabit
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
			Group {
				if asGrid {
					gridItem
				} else {
					listItem
				}
			}
				.contentShape(Rectangle())
		}
			.buttonStyle(.plain)
			.tint(habit.color)
			.contextMenu {
				contextActions
			}
			.swipeActions(edge: .trailing) {
				if !asGrid {
					contextActions
				}
			}
	}

	private var contextActions: some View {
		Group {
			Button {
				selectedHabit = habit
			} label: {
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

	private var habitTitle: some View {
		if habit.title.isEmpty {
			Text("Unlabeled")
				.foregroundStyle(.secondary)
		} else {
			Text(habit.title)
		}
	}
	private var habitStreak: some View {
		Group {
			if habit.completedStreak > 0 {
				Text("\(habit.completedStreak) streak")
					.font(.roundedCallout)
					.foregroundColor(.secondary)
			}
		}
	}
	private var habitDetails: some View {
		HStack(spacing: 0) {
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
			if !asGrid && habit.completedStreak > 0 {
				Text("・")
				habitStreak
			}
		}
			.font(.roundedCallout)
			.foregroundColor(.secondary)
	}

	private var listItem: some View {
		HStack {
			Image(systemName: !habit.icon.isEmpty ? habit.icon : "diamond")
				.imageScale(.large)
				.font(.system(size: 24))
				.frame(width: 44)
				.foregroundStyle(habit.color)
			VStack(alignment: .leading) {
				habitTitle
				habitDetails
			}
			Spacer()
			ProgressCircle(habit: habit, count: activeEntries.count, size: 28)
				.fixedSize(horizontal: true, vertical: false)
		}
	}

	private var gridItem: some View {
		VStack {
			ProgressCircle(habit: habit, count: activeEntries.count, size: 64)
				.overlay {
					Image(systemName: !habit.icon.isEmpty ? habit.icon : "diamond")
						.imageScale(.large)
						.font(.system(size: 24))
						.frame(width: 44)
						.foregroundStyle(habit.color)
				}
			habitTitle
			habitDetails
			habitStreak
		}
	}
}

#Preview {
	NavigationStack {
		List {
			HabitListItem(habit: PreviewModel.preview.habit, asGrid: false, selectedHabit: .constant(nil))
			HabitListItem(habit: PreviewModel.preview.habit, asGrid: true, selectedHabit: .constant(nil))
		}
	}
}
