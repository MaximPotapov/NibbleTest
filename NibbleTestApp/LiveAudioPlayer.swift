//
//  LiveAudioPlayer.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 21.03.2025.
//
import AVFAudio
import Combine

class LiveAudioPlayer: NSObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    private var currentSpeed: Double = 1.0
    private var pausedTime: TimeInterval = 0

    let subject: PassthroughSubject<Bool, Never> = .init()
//    private var cancellables: Set<AnyCancellable> = []
    
    func play(fileName: String, atTime: Double) async throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            throw NSError(domain: "AudioPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Audio file not found: \(fileName).mp3"])
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.currentTime = atTime
            audioPlayer?.enableRate = true
            audioPlayer?.rate = Float(currentSpeed)
            audioPlayer?.play()
            pausedTime = atTime
        } catch {
            print("Error playing audio: \(error)")
            throw error
        }
    }

    func resume() throws {
        guard let audioPlayer = audioPlayer else {
            throw NSError(domain: "AudioPlayer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Audio player not initialized."])
        }
        
        audioPlayer.currentTime = pausedTime
        audioPlayer.play()
    }

    func pause() throws {
        guard let audioPlayer else { return }
        pausedTime = audioPlayer.currentTime
        audioPlayer.pause()
    }

    func fastForward(timeInterval: TimeInterval) throws {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.currentTime = min(audioPlayer.duration, audioPlayer.currentTime + timeInterval)
        print("player current time:\(audioPlayer.currentTime)")
    }

    func rewind(timeInterval: TimeInterval) throws {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.currentTime = max(0, audioPlayer.currentTime - timeInterval)
    }

    func changeSpeed(speed: Double) throws {
        guard let audioPlayer = audioPlayer else { return }
        currentSpeed = speed
        audioPlayer.rate = Float(speed)
    }
    
    func seek(to progress: Double) throws {
        guard let audioPlayer else { return }
        audioPlayer.currentTime = progress * audioPlayer.duration
    }
    
    func currentTime() throws -> TimeInterval? {
        guard let audioPlayer = audioPlayer else { return nil }
        return audioPlayer.currentTime
    }
    
    func duration() throws -> TimeInterval? {
        guard let audioPlayer = audioPlayer else { return nil }
        return audioPlayer.duration
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        subject.send(flag)
    }
}
