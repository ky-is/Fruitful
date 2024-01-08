import Foundation
import SwiftData

func getSchema() -> Schema {
	Schema([
		Habit.self,
	])
}

@MainActor
struct AppModel {
	static let shared = AppModel()

	let container: ModelContainer

	init() {
		let schema = getSchema()
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		do {
			container = try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
#if DEBUG
			do {
				try FileManager.default.removeItem(at: modelConfiguration.url)
				container = try ModelContainer(for: schema, configurations: [modelConfiguration])
				return
			} catch {}
#endif
			fatalError("Could not create ModelContainer: \(error)")
		}
	}
}

@MainActor
struct PreviewModel {
	static let preview = PreviewModel()

	let container: ModelContainer
	let habit: Habit

	init() {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		do {
			container = try ModelContainer(for: getSchema(), configurations: config)
		} catch {
			fatalError("Could not create PreviewModelContainer: \(error)")
		}
		habit = Habit(title: "Test Test Test Test Test")
		habit.goalCount = 2
		container.mainContext.insert(habit)
	}
}

