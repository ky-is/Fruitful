import SwiftUI

struct ProgressCircle: View {
	let habit: Habit
	let count: Int
	let size: Double

	var body: some View {
		let lineWidth: Double = 6 // size / 6
		let progress = min(1, Double(count) / Double(habit.goalCount))
		let leafSize = pow(size * 8, 0.5)
		let inset = progress < 1 ? 0.025 : 0.09
		ZStack {
			if progress < 1 {
//				ForEach(0..<count, id: \.self) { index in
//					Circle()
//						.trim(from: Double(index) * countFraction + inset * 0, to: Double(index + 1) * countFraction - inset * 0)
//						.stroke(habit.color.tertiary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
//				}
//					.rotationEffect(.degrees(-90))
				Circle()
					.stroke(habit.color.tertiary, lineWidth: lineWidth)
			} else {
				Ellipse()
					.fill(habit.color)
					.rotationEffect(.degrees(38), anchor: .bottomLeading)
					.frame(width: leafSize * 0.4, height: leafSize)
					.position(x: size * 0.475 - lineWidth * 0.15, y: -size * 0.05 - lineWidth * 1)
			}
			Circle()
				.trim(from: inset, to: progress * (1 - inset))
				.stroke(habit.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
				.rotationEffect(.degrees(-90))
				.animation(.easeOut, value: progress)
		}
			.frame(maxWidth: size, maxHeight: size)
	}
}

#Preview {
	Group {
		ProgressCircle(habit: PreviewModel.preview.habit, count: 0, size: 28)
		ProgressCircle(habit: PreviewModel.preview.habit, count: 1, size: 28)
		ProgressCircle(habit: PreviewModel.preview.habit, count: 2, size: 28)
		ProgressCircle(habit: PreviewModel.preview.habit, count: 1, size: 64)
		ProgressCircle(habit: PreviewModel.preview.habit, count: 2, size: 64)
	}
		.padding()
}
