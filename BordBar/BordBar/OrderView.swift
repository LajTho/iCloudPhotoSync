import SwiftUI

/// Großanzeige nach der Bestellung – damit der „Getränkebote“ sieht, was gewünscht ist.
struct OrderView: View {
    let order: Order
    let onRepeat: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(order.drink.emoji)
                .font(.system(size: 140))
            Text(order.drink.callout)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Bordkarte \(order.card)")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Button(action: onRepeat) {
                Label("Nochmal klingeln", systemImage: "bell.and.waves.left.and.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            Button(action: onDone) {
                Label("Erledigt – Prost!", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

#Preview {
    OrderView(order: Order(drink: Drink.menu[2], card: "1234567890"), onRepeat: {}, onDone: {})
}
