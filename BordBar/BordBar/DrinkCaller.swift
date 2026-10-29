import AVFoundation

/// Läutet die Service-Klingel und ruft danach das gewünschte Getränk aus.
final class DrinkCaller: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var bell: AVAudioPlayer?

    override init() {
        super.init()
        synthesizer.delegate = self
        bell = Self.loadBell()
        bell?.prepareToPlay()
    }

    func call(for drink: Drink) {
        stop()
        activateAudioSession()

        bell?.currentTime = 0
        bell?.play()

        let utterance = AVSpeechUtterance(string: drink.callout)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        // Erst sprechen, wenn die Klingel verklungen ist.
        utterance.preUtteranceDelay = bell?.duration ?? 0
        synthesizer.speak(utterance)
    }

    /// Bricht Klingel und Ansage ab.
    func stop() {
        bell?.stop()
        synthesizer.stopSpeaking(at: .immediate)
        deactivateAudioSession()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        deactivateAudioSession()
    }

    private func activateAudioSession() {
        let session = AVAudioSession.sharedInstance()
        // .playback klingelt auch, wenn der Stummschalter aktiv ist.
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try? session.setActive(true)
    }

    private func deactivateAudioSession() {
        // Gibt gedimmte Musik anderer Apps wieder frei.
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Spielt „Klingel.wav“ aus dem App-Ordner; eine eigene Datei gleichen Namens
    /// (auch .m4a, .mp3 oder .caf) ersetzt den eingebauten Ton.
    private static func loadBell() -> AVAudioPlayer? {
        let url = ["wav", "m4a", "mp3", "caf"]
            .lazy
            .compactMap { Bundle.main.url(forResource: "Klingel", withExtension: $0) }
            .first
        return url.flatMap { try? AVAudioPlayer(contentsOf: $0) }
    }
}
