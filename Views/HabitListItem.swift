import SwiftUI
import SwiftData

struct HabitListItem: View {
	var habit: Habit

	var body: some View {
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
						Text(habit.activeEntry?.count ?? 0, format: .number)
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
			ProgressCircle(habit: habit, size: 24)
				.fixedSize(horizontal: true, vertical: false)
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
