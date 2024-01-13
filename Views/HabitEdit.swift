import SwiftUI
import SwiftData

struct HabitEdit: View {
	@Bindable var habit: Habit

	@Query private var allEntries: [HabitEntry]

	@Environment(\.self) private var environment
	@Environment(\.modelContext) private var modelContext

	@FocusState private var focusedField: FocusedField?

	@State private var updateEntry: HabitEntry?
	@State private var updateEntryCount = 0

	private enum FocusedField {
		case title, goalCount, notifyAt
	}

	init(habit: Habit) {
		self.habit = habit
		let id = habit.persistentModelID
		self._allEntries = Query(filter: #Predicate { entry in entry.habit.persistentModelID == id })
	}

	var entriesSection: some View {
		let showsPrompt = Binding {
			return updateEntry != nil
		} set: { _,_ in
			updateEntry = nil
		}
		return Section {
			ForEach(allEntries) { entry in
				HStack {
					Text(entry.count, format: .number)
					Text(entry.timestamp, format: .dateTime)
				}
					.onTapGesture {
						updateEntryCount = entry.count
						updateEntry = entry
					}
					.swipeActions(edge: .trailing) {
						Button("Delete", role: .destructive) {
							modelContext.delete(entry)
						}
					}
			}
		}
			.alert("Update count", isPresented: showsPrompt) {
				TextField("Entry count", value: $updateEntryCount, format: .number)
#if !os(macOS)
					.keyboardType(.numberPad)
#endif
					.submitLabel(.done)
				Button("Update") {
					withAnimation {
						if let updateEntry {
							updateEntry.count = updateEntryCount
							if updateEntry.habit.completedUntil == updateEntry.habit.intervalEndAt && updateEntry.count < updateEntry.habit.goalCount {
								updateEntry.habit.completedUntil = Date.distantPast
							}
						}
					}
				}
				Button("Cancel", role: .cancel) { }
			}
	}

	var body: some View {
		let tintColor = Color(cgColor: habit.color)
		Form {
			Section {
				Picker("Interval", selection: $habit.interval) {
					ForEach(HabitInterval.allCases, id: \.self) { interval in
						Text(interval.description.capitalized)
					}
				}
					.tint(Color(cgColor: habit.color))
				HStack {
					Text("Goal Count")
					TextField("Goal Count", value: $habit.goalCount, format: .number)
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
							//TODO
						} label: {
							let hasIcon = !habit.icon.isEmpty
							Image(systemName: hasIcon ? habit.icon : "questionmark.diamond.fill")
								.tint(hasIcon ? nil : tintColor.opacity(0.5))
						}
							.buttonStyle(.plain)
					}
					ColorPicker("Habit Color", selection: $habit.color, supportsOpacity: false)
						.labelsHidden()
				}
					.font(.title2)
					.textCase(nil)
					.tint(tintColor)
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
			entriesSection
		}
			.tint(tintColor)
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
					Task { @MainActor in
#if os(iOS)
						UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
#endif
					}
				}
			}
	}
}

#Preview {
	NavigationStack {
		HabitEdit(habit: PreviewModel.preview.habit)
	}
		.modelContainer(PreviewModel.preview.container)
}
