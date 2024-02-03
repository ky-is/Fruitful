import Foundation
import SwiftData

@MainActor
struct AppModel {
	static let shared = AppModel()

	let container: ModelContainer

	static func getSchema() -> Schema {
		Schema([
			Habit.self,
			HabitEntry.self,
		])
	}

	init() {
		let schema = Self.getSchema()
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		do {
//			container = try ModelContainer(for: schema, migrationPlan: FruitfulMigrationPlan.self, configurations: [modelConfiguration])
			container = try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
//#if DEBUG // Reset db
//			try? FileManager.default.removeItem(at: modelConfiguration.url)
//			container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
//#endif
			fatalError("Could not create ModelContainer: \(error)")
		}
#if DEBUG // Seed data
		do {
			let context = container.mainContext
			let habits = try context.fetch(FetchDescriptor<Habit>())
//			let habitEntries = try context.fetch(FetchDescriptor<HabitEntry>())
			if habits.isEmpty {
				seedHabits.forEach(context.insert)
				print("RELOAD seed data")
			} else {
//				habits.forEach { if $0.title.isEmpty { context.delete($0) } } //SAMPLE delete empty Habits
//				print(habits.map { "let \($0.title) = Habit(title: \"\($0.title)\", icon: \"\($0.icon)\", goalCount: \($0.goalCount), hexColor: \($0.hexColor))" }.joined(separator: "\n"))
//				print("let seedHabits: [Habit] = [\(habits.map { $0.title }.joined(separator: ", "))]")
//				print(habitEntries.map { "HabitEntry(habit: \($0.habit?.title ?? ""), timestamp: Date(timeIntervalSince1970: \(Int($0.timestamp.timeIntervalSince1970))))" }.joined(separator: ",\n\t")) //SAMPLE
			}
		} catch {
			print("Unable to load existing data")
		}
#endif
#if DEBUG // Migrate dev
		let context = container.mainContext
		let habits = try! context.fetch(FetchDescriptor<Habit>())
		habits.forEach { $0.priority = .normal }
		try! context.save()
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
		let entry = HabitEntry(habit: habit)
		container.mainContext.insert(entry)
	}
}
