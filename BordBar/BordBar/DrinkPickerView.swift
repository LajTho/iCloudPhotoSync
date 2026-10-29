import SwiftUI

/// Das Pop-up nach dem Scan: „Welches Getränk?“
struct DrinkPickerView: View {
    let card: String
    let onSelect: (Drink) -> Void

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Welches Getränk?")
                        .font(.title2.bold())
                    Text("Bordkarte \(card)")
                        .font(.footnote.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Drink.menu) { drink in
                        Button { onSelect(drink) } label: {
                            VStack(spacing: 6) {
                                Text(drink.emoji)
                                    .font(.system(size: 48))
                                Text(drink.name)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 110)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    Text("Kamera")
        .sheet(isPresented: .constant(true)) {
            DrinkPickerView(card: "1234567890") { _ in }
        }
}
