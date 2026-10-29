import AVFoundation
import SwiftUI

/// Kamera-Vorschau, die Barcodes erkennt und deren Inhalt meldet.
struct BarcodeScannerView: UIViewControllerRepresentable {
    /// Solange `true`, werden erkannte Codes ignoriert.
    var isPaused: Bool
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        ScannerViewController()
    }

    func updateUIViewController(_ controller: ScannerViewController, context: Context) {
        controller.isPaused = isPaused
        controller.onScan = onScan
    }
}

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var isPaused = false
    var onScan: ((String) -> Void)?

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "BordBar.scanner")
    private var previewLayer: AVCaptureVideoPreviewLayer?

    /// Alle gängigen Codes – welchen Typ die Bordkarte nutzt, spielt so keine Rolle.
    private static let symbologies: [AVMetadataObject.ObjectType] = [
        .qr, .pdf417, .aztec, .dataMatrix,
        .code128, .code39, .code39Mod43, .code93,
        .ean13, .ean8, .upce, .itf14, .interleaved2of5,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let session = self.session
        sessionQueue.async {
            if !session.isRunning { session.startRunning() }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let session = self.session
        sessionQueue.async {
            if session.isRunning { session.stopRunning() }
        }
    }

    private func configureSession() {
        guard let device = Self.backCamera(),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        // Welche Codes das Gerät kann, steht erst nach addOutput fest.
        let available = output.availableMetadataObjectTypes
        output.metadataObjectTypes = Self.symbologies.filter { available.contains($0) }

        prepareForCloseUps(device)

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        previewLayer = layer
    }

    /// Mehrlinsige Kameras wechseln bei Nahaufnahmen selbst ins Makro – wichtig,
    /// weil Pro-iPhones mit dem Hauptobjektiv erst ab etwa 20 cm scharf stellen.
    private static func backCamera() -> AVCaptureDevice? {
        let types: [AVCaptureDevice.DeviceType] = [.builtInTripleCamera, .builtInDualWideCamera, .builtInWideAngleCamera]
        return types.lazy
            .compactMap { AVCaptureDevice.default($0, for: .video, position: .back) }
            .first
    }

    private func prepareForCloseUps(_ device: AVCaptureDevice) {
        guard (try? device.lockForConfiguration()) != nil else { return }
        defer { device.unlockForConfiguration() }
        // Virtuelle Kameras starten im Ultraweitwinkel (0,5×) – auf das normale 1× zoomen.
        if let wideAngleZoom = device.virtualDeviceSwitchOverVideoZoomFactors.first {
            device.videoZoomFactor = CGFloat(truncating: wideAngleZoom)
        }
        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }
    }

    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput,
                                    didOutput metadataObjects: [AVMetadataObject],
                                    from connection: AVCaptureConnection) {
        guard let code = metadataObjects
            .compactMap({ ($0 as? AVMetadataMachineReadableCodeObject)?.stringValue })
            .first(where: { !$0.isEmpty }) else { return }
        // Der Delegate läuft auf der Main-Queue (siehe setMetadataObjectsDelegate).
        MainActor.assumeIsolated {
            guard !isPaused else { return }
            onScan?(code)
        }
    }
}
