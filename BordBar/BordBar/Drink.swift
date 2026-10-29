import Foundation

struct Drink: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    /// Wird nach der Klingel vorgelesen und groß auf dem Display angezeigt.
    let callout: String

    /// Die Getränkekarte – hier ergänzen, umbenennen oder streichen.
    static let menu: [Drink] = [
        Drink(id: "kaffee", name: "Kaffee", emoji: "☕️", callout: "Einen Kaffee, bitte!"),
        Drink(id: "bier", name: "Bier", emoji: "🍺", callout: "Ein Bier, bitte!"),
        Drink(id: "aperol", name: "Aperol Spritz", emoji: "🍹", callout: "Einen Aperol Spritz, bitte!"),
        Drink(id: "gintonic", name: "Gin Tonic", emoji: "🍸", callout: "Einen Gin Tonic, bitte!"),
        Drink(id: "icerose", name: "Ice Rosé", emoji: "🍷", callout: "Einen Ice Rosé, bitte!"),
    ]
}

/// Ein ausgewähltes Getränk samt der Bordkarte, mit der bestellt wurde.
struct Order: Equatable {
    let drink: Drink
    let card: String
}
