//
//  AudioPlayerProvider.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 21.03.2025.
//

import Foundation
import ComposableArchitecture
@preconcurrency import Combine

struct AudioPlayerProvider: Sendable {
    var play: @Sendable (String, Double) async throws -> Void
    var resume: @Sendable () async throws -> Void
    var pause: @Sendable () async throws -> Void
    var fastForward: @Sendable (TimeInterval) async throws -> Void
    var rewind: @Sendable (TimeInterval) async throws -> Void
    var changeSpeed: @Sendable (Double) async throws -> Void
    var seek: @Sendable (Double) async throws -> Void
    var currentTime: @Sendable () async throws -> TimeInterval
    var duration: @Sendable () async throws -> TimeInterval
    var didFinishPlaying: any Publisher<Bool, Never>
}

extension AudioPlayerProvider: DependencyKey {
    static var liveValue = {
        let livePlayer = LiveAudioPlayer()
        
        return AudioPlayerProvider(
            play: { fileName, atTime in
                try livePlayer.play(fileName: fileName, atTime: atTime)
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
            didFinishPlaying: livePlayer.didFinishPlaying
        )
    }()
}

extension DependencyValues {
    var audioPlayerProvider: AudioPlayerProvider {
        get { self[AudioPlayerProvider.self] }
        set { self[AudioPlayerProvider.self] = newValue }
    }
}
