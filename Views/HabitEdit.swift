import SwiftUI

struct HabitEdit: View {
	@Bindable var habit: Habit

	@Environment(\.self) private var environment
	@FocusState private var focusedField: FocusedField?

	private enum FocusedField {
		case title, goalCount, notifyAt
	}

	var body: some View {
		let tintColor = Color(cgColor: habit.color)
		Form {
			Section {
				Picker("Interval", selection: $habit.interval) {
					ForEach(HabitInterval.allCases, id: \.self) { interval in
						Text(interval.description)
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
