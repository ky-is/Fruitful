import SwiftUI
import SwiftData

@main
struct FruitfulApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
			.modelContainer(AppModel.shared.container)
	}
}
