import SwiftUI

struct ProgressCircle: View {
	let habit: Habit
	let count: Int
	let size: Double

	var body: some View {
		let color = Color(cgColor: habit.color)
		let lineWidth = size / 6
		let progress = Double(count) / Double(habit.goalCount)
		ZStack {
			Circle()
				.stroke(color.tertiary, lineWidth: lineWidth)
			Circle()
				.trim(from: 0, to: progress)
				.stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
				.rotationEffect(.degrees(-90))
				.animation(.easeOut, value: progress)
		}
			.frame(maxWidth: size, maxHeight: size)
	}
}

#Preview {
	ProgressCircle(habit: PreviewModel.preview.habit, count: 1, size: 32)
}
