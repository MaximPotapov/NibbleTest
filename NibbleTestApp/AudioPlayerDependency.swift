//
//  AudioPlayerDependency.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 21.03.2025.
//
import ComposableArchitecture

extension AudioPlayerProvider: DependencyKey {
    static var liveValue = {
        let livePlayer = LiveAudioPlayer()
        
        return AudioPlayerProvider(
            play: { fileName, atTime in
                try await livePlayer.play(fileName: fileName, atTime: atTime)
            },
            resume: {
                try livePlayer.resume()
            },
            pause: {
                try livePlayer.pause()
            },
            fastForward: { timeInterval in
                try livePlayer.fastForward(timeInterval: timeInterval)
            },
            rewind: { timeInterval in
                try livePlayer.rewind(timeInterval: timeInterval)
            },
            changeSpeed: { speed in
                try livePlayer.changeSpeed(speed: speed)
            },
            seek: { progress in
                try livePlayer.seek(to: progress)
            },
            currentTime: {
                try livePlayer.currentTime() ?? 0.0
            },
            duration: {
                try livePlayer.duration() ?? 0.0
            },
            didFinishPlaying: livePlayer.subject.eraseToAnyPublisher()
        )
    }()
}

extension DependencyValues {
    var audioPlayerProvider: AudioPlayerProvider {
        get { self[AudioPlayerProvider.self] }
        set { self[AudioPlayerProvider.self] = newValue }
    }
}
