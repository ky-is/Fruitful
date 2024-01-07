import Foundation
import SwiftData

func getSchema() -> Schema {
	Schema([
		Habit.self,
	])
}

@MainActor
struct PreviewModel {
	static let preview = PreviewModel()

	let container: ModelContainer
	let habit: Habit

	init() {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		habit = Habit(title: "Test")
		do {
			container = try ModelContainer(for: getSchema(), configurations: config)
			container.mainContext.insert(habit)
		} catch {
			fatalError("Could not create PreviewModel: \(error)")
		}
	}
}
