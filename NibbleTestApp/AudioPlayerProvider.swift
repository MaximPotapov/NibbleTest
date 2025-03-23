//
//  AudioPlayerProvider.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 21.03.2025.
//

import Foundation
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
    var didFinishPlaying: AnyPublisher<Bool, Never>
}
