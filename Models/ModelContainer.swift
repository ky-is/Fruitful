import Foundation
import SwiftData

@MainActor
struct AppModel {
	static let shared = AppModel()

	let container: ModelContainer

	static func getSchema() -> Schema {
		Schema([
			Habit.self,
		])
	}

	init() {
		let schema = Self.getSchema()
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		do {
			container = try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
#if DEBUG
			try? FileManager.default.removeItem(at: modelConfiguration.url)
			container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
#else
			fatalError("Could not create ModelContainer: \(error)")
#endif
		}
#if DEBUG
		do {
			let context = container.mainContext
			let habits = try context.fetch(FetchDescriptor<Habit>())
			if habits.isEmpty {
				seedHabits.forEach(context.insert)
			} else {
				print(habits.map { "\($0.title) \($0.hexColor)" }) //SAMPLE
			}
		} catch {
			print("Unable to load existing data")
		}
#endif
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
			container = try ModelContainer(for: AppModel.getSchema(), configurations: config)
		} catch {
			fatalError("Could not create PreviewModelContainer: \(error)")
		}
		habit = Habit(title: "Test Test Test Test Test")
		habit.goalCount = 2
		container.mainContext.insert(habit)
	}
}
