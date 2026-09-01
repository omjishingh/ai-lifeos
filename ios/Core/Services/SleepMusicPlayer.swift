import Foundation
import AVFoundation

@MainActor
@Observable
final class SleepMusicPlayer: NSObject {
    private var player: AVAudioPlayer?
    var isPlaying = false
    var selectedSound: String = "rain"
    var timerMinutes: Int = 30
    private var sleepTimer: Timer?

    override init() {
        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    func play(sound: String? = nil) {
        if let sound { selectedSound = sound }
        stop()

        guard let url = Bundle.main.url(forResource: selectedSound, withExtension: "mp3") else {
            playGeneratedNoise()
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            startSleepTimer()
        } catch {
            playGeneratedNoise()
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        sleepTimer?.invalidate()
        sleepTimer = nil
    }

    func setTimer(minutes: Int) {
        timerMinutes = minutes
        if isPlaying { startSleepTimer() }
    }

    private func startSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = Timer.scheduledTimer(withTimeInterval: Double(timerMinutes * 60), repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.stop()
            }
        }
    }

    private func playGeneratedNoise() {
        isPlaying = true
        startSleepTimer()
    }

    static let soundOptions: [(id: String, name: String, icon: String)] = [
        ("rain", "Rain", "cloud.rain.fill"),
        ("forest", "Forest", "tree.fill"),
        ("ocean", "Ocean", "water.waves"),
        ("white_noise", "White Noise", "waveform"),
        ("ambient", "Ambient", "music.note")
    ]
}
