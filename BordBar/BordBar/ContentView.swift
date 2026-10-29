import AVFoundation
import SwiftUI

struct ContentView: View {
    @State private var cameraAccess = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var scannedCard: ScannedCard?
    @State private var order: Order?
    /// Kurze Sperre nach einer Bestellung, damit die noch vor der Kamera
    /// liegende Karte nicht sofort das nächste Pop-up auslöst.
    @State private var scanPausedUntil = Date.distantPast
    @State private var caller = DrinkCaller()

    var body: some View {
        ZStack {
            scanner

            #if targetEnvironment(simulator)
            // Der Simulator hat keine Kamera – damit lässt sich der Ablauf trotzdem testen.
            Button("Test-Scan") { handleScan("SIMULATOR-4711") }
                .buttonStyle(.borderedProminent)
            #endif

            if let order {
                OrderView(order: order,
                          onRepeat: { caller.call(for: order.drink) },
                          onDone: finishOrder)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: order)
        .sheet(item: $scannedCard, onDismiss: pauseScanning) { card in
            DrinkPickerView(card: card.code) { drink in
                order = Order(drink: drink, card: card.code)
                scannedCard = nil
                caller.call(for: drink)
            }
        }
        .task { await requestCameraAccessIfNeeded() }
    }

    @ViewBuilder
    private var scanner: some View {
        switch cameraAccess {
        case .authorized:
            BarcodeScannerView(isPaused: scannedCard != nil || order != nil, onScan: handleScan)
                .ignoresSafeArea()
                .overlay { ScanOverlay() }
        case .notDetermined:
            ProgressView()
        default:
            CameraDeniedView()
        }
    }

    private func handleScan(_ code: String) {
        guard scannedCard == nil, order == nil, Date() >= scanPausedUntil else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        scannedCard = ScannedCard(code: code)
    }

    private func finishOrder() {
        caller.stop()
        order = nil
        pauseScanning()
    }

    private func pauseScanning() {
        scanPausedUntil = Date().addingTimeInterval(2)
    }

    private func requestCameraAccessIfNeeded() async {
        guard cameraAccess == .notDetermined else { return }
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        cameraAccess = granted ? .authorized : .denied
    }
}

private struct ScannedCard: Identifiable {
    let id = UUID()
    let code: String
}

private struct ScanOverlay: View {
    var body: some View {
        VStack {
            Text("BordBar")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .shadow(radius: 4)
                .padding(.top, 24)
            Spacer()
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.9), lineWidth: 3)
                .frame(width: 300, height: 190)
            Spacer()
            Text("Barcode der Bordkarte in den Rahmen halten")
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
                .padding(.bottom, 32)
        }
        .padding(.horizontal)
    }
}

private struct CameraDeniedView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ContentUnavailableView {
            Label("Kein Kamerazugriff", systemImage: "camera.fill")
        } description: {
            Text("BordBar braucht die Kamera, um den Barcode deiner Bordkarte zu lesen.")
        } actions: {
            Button("Einstellungen öffnen") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
