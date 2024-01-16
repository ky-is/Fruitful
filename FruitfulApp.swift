import SwiftUI
import SwiftData

@main
struct FruitfulApp: App {
#if !os(macOS)
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
#endif

	var body: some Scene {
		WindowGroup {
			ContentView()
				.font(.body)
		}
			.modelContainer(AppModel.shared.container)
	}
}

#if !os(macOS)
final class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont.rounded(style: .largeTitle, bold: true)]
		UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.rounded(style: .headline, bold: false)]

		UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont.rounded(style: .subheadline, bold: true)], for: .selected)
		UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont.rounded(style: .subheadline, bold: false)], for: .normal)

		UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .accentColor
		return true
	}
}
#endif
