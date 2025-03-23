//
//  PlayerFeature.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 20.03.2025.
//

// Potential issues:
// TODO: Slider is not working when trying to change progress manually
// TODO: When using fast-forward or backward, current time is not updated properly

import ComposableArchitecture
import SwiftUI
import Dependencies
import Combine

@Reducer
struct PlayerFeature {
    @ObservableState
    struct State: Equatable {
        var book: Book?
        var currentBookCover: String?
        var audioFileName: String?
        var currentChapterIndex: Int = 0
        
        var isPlaying: Bool = false
        var isShowingAlert: Bool = false
        var isShowingSpeedOptions: Bool = false
        
        var speed: Double = 1.0
        var progress: Double = 0
        var currentDuration: TimeInterval = 0
        var currentTime: TimeInterval = 0
        var sliderValue = 0.0
        var error: PlayerErrorType?
        
        enum PlayerErrorType {
            case bookNotLoaded
            case chapterNotLoaded
            case playerNotInitialized
            case other
            
            var title: String {
                switch self {
                case .bookNotLoaded: return "Error loading a book 🥲"
                case .chapterNotLoaded: return "Error loading chapter 🥲"
                case .playerNotInitialized: return "Player playback error 🥲"
                case .other: return "Oops, something went wrong 🥲"
                }
            }
        }
        
        enum ChapterChangeDirection {
            case previous
            case next
        }
    }
    
    enum Action: Equatable {
        // scene events
        case loadBook
        case playAudio(String)
        case timerTick
        case dismissAlert
        case displayAlert

        // book effects
        case bookLoaded(Book?)
        
        // player controls
        case speedButtonTapped
        case speedSelected(Double)
        case playPauseButtonTapped
        case forward10SecondsTapped
        case backward5SecondsTapped
        case previousButtonTapped
        case nextButtonTapped
        
        // player effects
        case previousButtonTappedEffect
        case nextButtonTappedEffect
        
        // observable
        case observeCurrentDuration
        case observePlayerClient
        
        // player effects
        case pauseAudio
        case resumeAudio
        case setShowSpeedOptions(Bool)
        case fetchAudioDuration(TimeInterval)
        case fetchCurrentTime(TimeInterval)
        case fetchCurrentProgress(Double)
        case updateSliderValue(Double)
        case seek(Double)
        case audioPlaybackFinished(Bool)
    }
    
    private enum CancelID { case progress }
    private enum ObservePlayerClientID { case chapter }
    
    @Dependency(\.audioPlayerProvider) var audioPlayerProvider
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                // Scene Events
            case .loadBook:
                return .run { send in
                    await loadBookEffect(send: send)
                }

            case .playAudio(let fileName):
                state.isPlaying = true
                return .run { send in
                    try await audioPlayerProvider.play(fileName, 0)
                    await send(.observeCurrentDuration)
                    await send(.observePlayerClient)
                    await send(.fetchAudioDuration(try await audioPlayerProvider.duration()))
                }

            case .timerTick:
                return .run { send in
                    await send(.fetchCurrentTime(try await audioPlayerProvider.currentTime()))
                }

            case .dismissAlert:
                state.isShowingAlert = false
                return .none

            case .displayAlert:
                state.isShowingAlert = true
                return .send(.pauseAudio)

                // Book Effects
            case .bookLoaded(let book):
                state.book = book
                guard let book = book else {
                    state.error = .bookNotLoaded
                    return .send(.displayAlert)
                }

                guard let firstChapter = book.chapters.first else {
                    state.error = .chapterNotLoaded
                    state.isShowingAlert = true
                    return .none
                }

                state.audioFileName = firstChapter.audio
                return .run { [audioFileName = firstChapter.audio] send in
                    await send(.playAudio(audioFileName ?? ""))
                }

                // Player Controls
            case .speedButtonTapped:
                return .send(.setShowSpeedOptions(true))

            case .speedSelected(let newSpeed):
                state.speed = newSpeed
                return .run { [newSpeed] send in
                    try await changeSpeedEffect(new: newSpeed, send: send)
                }

            case .playPauseButtonTapped:
                return .send(state.isPlaying ? .pauseAudio : .resumeAudio)

            case .forward10SecondsTapped:
                return .run { send in
                    try await audioPlayerProvider.fastForward(10)
                    await send(.fetchCurrentTime(try await audioPlayerProvider.currentTime()))
                    if try await audioPlayerProvider.currentTime() > 0 {
                        await send(.fetchCurrentProgress(try await audioPlayerProvider.currentTime() / audioPlayerProvider.duration()))
                    }
                }

            case .backward5SecondsTapped:
                return .run { send in
                    try await audioPlayerProvider.rewind(5)
                    await send(.fetchCurrentTime(try await audioPlayerProvider.currentTime()))
                }

            case .previousButtonTapped:
                return .merge(
                    .cancel(id: ObservePlayerClientID.chapter),
                    .cancel(id: CancelID.progress),
                    .run { send in
                        await send(.previousButtonTappedEffect)
                    }
                )

            case .nextButtonTapped:
                return .merge(
                    .cancel(id: ObservePlayerClientID.chapter),
                    .cancel(id: CancelID.progress),
                    .run { send in
                        await send(.nextButtonTappedEffect)
                    }
                )

                // Player Effects
            case .previousButtonTappedEffect:
                state = changeChapter(state: state, direction: .previous)
                return state.error == nil ? .send(.playAudio(state.audioFileName!)) : .send(.displayAlert)

            case .nextButtonTappedEffect:
                state = changeChapter(state: state, direction: .next)
                return state.error == nil ? .send(.playAudio(state.audioFileName!)) : .send(.displayAlert)

                // Observable
            case .observeCurrentDuration:
                return .run { send in
                    while !Task.isCancelled {
                        await send(.timerTick)
                        try await self.clock.sleep(for: .seconds(1))
                    }
                }
                .cancellable(id: CancelID.progress)

            case .observePlayerClient:
                return .run { send in
                    for await value in audioPlayerProvider.didFinishPlaying.first().values {
                        await send(.audioPlaybackFinished(value))
                    }
                }
                .cancellable(id: ObservePlayerClientID.chapter)

                // Player Effects
            case .pauseAudio:
                state.isPlaying = false
                Task {
                    try await audioPlayerProvider.pause()
                }
                return .none

            case .resumeAudio:
                state.isPlaying = true
                Task {
                    try await audioPlayerProvider.resume()
                }
                return .none

            case .setShowSpeedOptions(let show):
                state.isShowingSpeedOptions = show
                return .none

            case .fetchAudioDuration(let duration):
                state.currentDuration = duration
                return .none

            case .fetchCurrentTime(let time):
                state.currentTime = time
                return .none

            case .fetchCurrentProgress(let progress):
                state.progress = progress
                return .none

            case .updateSliderValue(let progress):
                state.sliderValue = progress
                return .none
            
            case .seek(let progress):
                let targetTime = max(0, min(progress * state.currentDuration, state.currentDuration))

                return .run { send in
                    try await audioPlayerProvider.seek(targetTime)
                    await send(.fetchCurrentTime(targetTime))
                    await send(.fetchCurrentProgress(progress))
                }

            case .audioPlaybackFinished(let success):
                return .merge(
                    .cancel(id: ObservePlayerClientID.chapter),
                    .cancel(id: CancelID.progress),
                    .run { send in
                        if success {
                            await send(.nextButtonTappedEffect)
                        }
                    }
                )
            }
        }
    }
}

// MARK: Effects
private extension PlayerFeature {
    func changeChapter(state: State, direction: State.ChapterChangeDirection) -> State {
        guard let book = state.book else {
            return State(error: .bookNotLoaded)
        }
        
        var newState = state
        let chapterCount = book.chapters.count
        
        let newChapterIndex = direction == .previous
        ? (newState.currentChapterIndex - 1 + chapterCount) % chapterCount
        : (newState.currentChapterIndex + 1) % chapterCount
        
        let chapter = book.chapters[newChapterIndex]
        newState.currentChapterIndex = newChapterIndex
        newState.currentBookCover = chapter.image
        newState.audioFileName = chapter.audio
        newState.progress = 0
        newState.sliderValue = 0
        newState.currentTime = 0
        
        return newState
    }
    
    func loadBookEffect(send: Send<Action>) async {
        let book = BookDataProvider.loadBookData(from: "book")
        await send(.bookLoaded(book))
    }
    
    func changeSpeedEffect(new value: Double, send: Send<Action>) async throws {
        try await audioPlayerProvider.changeSpeed(value)
        await send(.setShowSpeedOptions(false))
    }
}

