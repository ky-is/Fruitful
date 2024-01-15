import SwiftUI

struct SymbolPickerPopover: ViewModifier {
	@Binding var show: Bool
	@Binding var name: String
	let accentColor: Color?

	@Environment(\.dismiss) private var dismiss

	func body(content: Content) -> some View {
		content
			.popover(isPresented: $show) {
				NavigationStack {
					SymbolPicker(name: $name)
						.navigationTitle("Choose an Icon")
						.toolbar {
							Button("Dismiss", role: .cancel) { dismiss() }
						}
						.tint(accentColor)
				}
			}
	}
}

private struct SymbolPicker: View {
	@Binding var name: String

	@State private var searchText = ""

	@Environment(\.dismiss) private var dismiss

	private let gridSize: Double = 64

	var body: some View {
		let filteredSymbols = searchText.isEmpty ? symbols : symbols.filter { $0.localizedCaseInsensitiveContains(searchText) }
		let symbolSize = gridSize * 0.5
		let cornerSize = gridSize * 0.2
		ScrollView {
			LazyVGrid(columns: [.init(.adaptive(minimum: gridSize, maximum: gridSize))]) {
				ForEach(filteredSymbols, id: \.self) { symbolName in
					let isSelected = symbolName == name
					Button {
						name = symbolName
						dismiss()
					} label: {
						if isSelected {
							Image(systemName: symbolName)
								.frame(maxWidth: .infinity, minHeight: gridSize)
								.background(.tint, in: .rect(cornerSize: .init(width: cornerSize, height: cornerSize), style: .continuous))
								.foregroundColor(.background)
						} else {
							Image(systemName: symbolName)
								.frame(maxWidth: .infinity, minHeight: gridSize)
						}
					}
						.disabled(isSelected)
				}
			}
				.font(.system(size: symbolSize))
				.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
		}
	}
}

#Preview {
	Spacer()
		.modifier(SymbolPickerPopover(show: .constant(true), name: .constant(""), accentColor: nil))
}
