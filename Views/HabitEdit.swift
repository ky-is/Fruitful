import SwiftUI
import SwiftData

struct HabitEditEntry: View {
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

struct HabitEdit: View {
	@Bindable var habit: Habit

	@Query private var allEntries: [HabitEntry]

	@Environment(\.self) private var environment
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss

	@FocusState private var focusedField: FocusedField?

	@State private var updateEntry: HabitEntry?
	@State private var showIcons = false
	@State private var showDeleteConfirmation = false

	private enum FocusedField {
		case title, goalCount, notifyAt
	}

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
	}

	var entriesSection: some View {
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

	var body: some View {
		Form {
			Section {
				Picker("Interval", selection: $habit.interval) {
					ForEach(HabitInterval.allCases, id: \.self) { interval in
						Text(interval.description.capitalized)
					}
				}
					.tint(habit.color)
				LabeledContent("Goal Count") {
					TextField("Goal Count", value: $habit.goalCount, format: .number)
						.labelsHidden()
						.focused($focusedField, equals: .goalCount)
#if !os(macOS)
						.keyboardType(.decimalPad)
#endif
				}
					.onTapGesture { focusedField = .goalCount }
			} header: {
				HStack {
					Label {
						TextField("Name", text: $habit.title)
							.focused($focusedField, equals: .title)
#if !os(macOS)
							.textInputAutocapitalization(.words)
							.foregroundStyle(Color(uiColor: .label))
#endif
					} icon: {
						Button {
							showIcons = true
						} label: {
							let hasIcon = !habit.icon.isEmpty
							Image(systemName: hasIcon ? habit.icon : "questionmark.diamond.fill")
								.imageScale(.large)
								.foregroundStyle(hasIcon ? habit.color : .secondary)
								.frame(minWidth: 40)
						}
							.buttonStyle(.plain)
					}
					ColorPicker("Habit Color", selection: $habit.cgColor, supportsOpacity: false)
						.labelsHidden()
				}
					.font(.title2)
					.textCase(nil)
					.padding(.bottom)
					.padding(.leading, -16)
			}
			Section {
				Toggle("Reminder", isOn: $habit.notifyEnabled)
				if (habit.notifyEnabled) {
					DatePicker("Reminder At", selection: $habit.notifyAt, displayedComponents: .hourAndMinute)
						.focused($focusedField, equals: .notifyAt)
				}
			}
			Section {
				Picker("Priority", selection: $habit.priority) {
					ForEach(HabitPriority.allCases, id: \.self) { priority in
						Label(priority.description.capitalized, systemImage: priority.icon)
					}
				}
					.tint(habit.color)
			}
			entriesSection
		}
			.tint(habit.color)
			.defaultFocus($focusedField, .title, priority: .userInitiated)
			.multilineTextAlignment(.trailing)
			.onChange(of: habit.notifyEnabled) { oldValue, notifyEnabled in
				if notifyEnabled {
					Task { @MainActor in
						focusedField = .notifyAt
					}
				}
			}
			.onChange(of: focusedField) { oldValue, focusedField in
				if focusedField != nil {
#if os(iOS)
					Task { @MainActor in
						UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
					}
#endif
				}
			}
			.toolbar {
				ToolbarItem(placement: .destructiveAction) {
					Button("Archive...") {
						showDeleteConfirmation.toggle()
					}
				}
			}
			.modifier(SymbolPickerPopover(show: $showIcons, name: $habit.icon, color: habit.color))
			.confirmationDialog("Delete or archive \(habit.title)", isPresented: $showDeleteConfirmation) {
				Button("Permanently Delete", role: .destructive) {
					modelContext.delete(habit)
					dismiss()
				}
				Button("Archive") {
					habit.archived = true
				}
			} message: {
				Text("Archive this habit to hide it from view while preserving your history for the activity")
			}
	}
}

#Preview {
	NavigationStack {
		HabitEdit(habit: PreviewModel.preview.habit)
	}
		.modelContainer(PreviewModel.preview.container)
}
