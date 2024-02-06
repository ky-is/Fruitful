import SwiftUI
import SwiftData

private struct HabitEditEntry: View {
	@Bindable var entry: HabitEntry

	var body: some View {
		VStack {
			TextField("Count:", value: $entry.count, format: .number)
				.labelStyle(.titleOnly)
#if !os(macOS)
				.keyboardType(.decimalPad)
#endif
//			LabeledContent("Count:") {
//					.labelsHidden()
//			}
			DatePicker("Timestamp:", selection: $entry.timestamp)
		}
	}
}

struct HabitEditEntries: View {
	@Bindable var habit: Habit

	@Query private var allEntries: [HabitEntry]

	@Environment(\.self) private var environment
	@Environment(\.modelContext) private var modelContext

	@State private var updateEntry: HabitEntry?

	init(habit: Habit) {
		self.habit = habit
		let id = habit.persistentModelID
		self._allEntries = Query(filter: #Predicate { entry in entry.habit?.persistentModelID == id })
	}

	private func recalculateCompleted(entry: HabitEntry, newCount: Int) {
		let startAt = habit.intervalStartAt
		let activeCount = allEntries
			.filter { $0.timestamp > startAt }
			.reduce(0) { acc, e in acc + (e != entry ? e.count : newCount) }
		habit.updateCompleted(newCount: activeCount)
		//TODO recalculate streak
	}

	var body: some View {
		Section {
			ForEach(allEntries) { entry in
				ZStack {
					Color.clear
						.contentShape(.rect)
						.onTapGesture {
							updateEntry = entry == updateEntry ? nil : entry
						}
					if entry == updateEntry {
						HabitEditEntry(entry: entry)
							.onChange(of: entry.count) { oldValue, newValue in
								recalculateCompleted(entry: entry, newCount: newValue)
							}
							.onChange(of: entry.timestamp) { oldValue, newValue in
								recalculateCompleted(entry: entry, newCount: newValue > habit.intervalStartAt ? entry.count : 0)
							}
					} else {
						HStack {
							Text(entry.count, format: .number)
							Spacer()
							Text(entry.timestamp, format: .dateTime)
						}
					}
				}
					.swipeActions(edge: .trailing) {
						Button("Delete", role: .destructive) {
							modelContext.delete(entry)
							recalculateCompleted(entry: entry, newCount: 0)
						}
					}
			}
		}
	}
}

#Preview {
	Form {
		HabitEditEntries(habit: PreviewModel.preview.habit)
	}
		.modelContainer(PreviewModel.preview.container)
}
