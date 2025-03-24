//
//  LiveAudioPlayer.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 21.03.2025.
//

import AVFAudio
@preconcurrency import Combine

actor LiveAudioPlayer {
    private var audioPlayer: AVAudioPlayer?
    private var currentSpeed: Double = 1.0
    private var pausedTime: TimeInterval = 0
    private let delegateHandler: DelegateHandler
    private let didFinishPlayingSubject: PassthroughSubject<Bool, Never> = .init()
    
    nonisolated var didFinishPlaying: some Publisher<Bool, Never> {
        didFinishPlayingSubject
    }
    
    init() {
        self.delegateHandler = DelegateHandler()
        self.delegateHandler.actor = self
    }
    
    func play(fileName: String, atTime: Double) throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            throw NSError(domain: "AudioPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Audio file not found: \(fileName).mp3"])
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = delegateHandler
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
        guard let audioPlayer else {
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
        guard let audioPlayer else { return }
        let newTime = min(audioPlayer.duration, audioPlayer.currentTime + timeInterval)
        audioPlayer.currentTime = newTime
        pausedTime = audioPlayer.currentTime
    }
    
    func rewind(timeInterval: TimeInterval) throws {
        guard let audioPlayer else { return }
        let newTime = max(0, audioPlayer.currentTime - timeInterval)
        audioPlayer.currentTime = newTime
        pausedTime = audioPlayer.currentTime
    }

    func changeSpeed(speed: Double) throws {
        guard let audioPlayer else { return }
        currentSpeed = speed
        audioPlayer.rate = Float(speed)
    }
    
    func seek(to progress: Double) throws {
        guard let audioPlayer else { return }
        audioPlayer.currentTime = progress * audioPlayer.duration
        pausedTime = audioPlayer.currentTime
    }
    
    func currentTime() throws -> TimeInterval? {
        guard let audioPlayer else { return nil }
        return audioPlayer.currentTime
    }
    
    func duration() throws -> TimeInterval? {
        guard let audioPlayer else { return nil }
        return audioPlayer.duration
    }

    func handlePlaybackFinished(_ flag: Bool) {
        didFinishPlayingSubject.send(flag)
    }
    
    private class DelegateHandler: NSObject, AVAudioPlayerDelegate {
        weak var actor: LiveAudioPlayer?
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            Task {
                await actor?.handlePlaybackFinished(flag)
            }
        }
    }
}
