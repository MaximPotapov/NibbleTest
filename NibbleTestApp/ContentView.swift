//
//  ContentView.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 18.03.2025.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @SwiftUI.Bindable var store: StoreOf<PlayerFeature>
    
    var body: some View {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea(.all)
                
                VStack  {
                    if let book = store.book {
                        
                        Spacer()
                        
                        Image(store.currentBookCover ?? book.bookCover)
                            .resizable()
                            .cornerRadius(8)
                            .scaledToFit()
                            .padding()
                        
                        infoView(book: book)
                        
                        progressView(book: book)
                        
                        playbackSpeedButton
                        
                        playerContols
                        
                        bottomMenu
                        
                    } else {
                        Text("Loading...")
                    }
                }
                .padding()
                .onAppear {
                    store.send(.loadBook)
                }
                .alert(store.error?.title ?? "", isPresented: Binding(
                    get: { store.isShowingAlert },
                    set: { _, _ in }
                )) {
                    Button("OK", role: .cancel) {
                        store.send(.dismissAlert)
                    }
                }
            }
    }
    
    private func infoView(book: Book) -> some View {
        VStack {
            if store.currentChapterIndex < book.chapters.count {
                let chapter = book.chapters[store.currentChapterIndex]
                
                Text(chapter.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(chapter.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("CHAPTER \(store.currentChapterIndex + 1) OF \(book.chapters.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
            } else {
                
            }
        }
    }
    
    private func progressView(book: Book) -> some View {
        HStack {
            Text(formatTime(time: store.currentTime))
                .font(.caption)
                .foregroundColor(.gray)
        
            Slider(
                value: $store.sliderValue.sending(\.updateSliderValue),
                in: 0...Double(store.currentDuration)
            )
            
            Text(self.chapterDuration(duration: store.currentDuration))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
    
    private var playbackSpeedButton: some View {
        VStack {
            Button(action: {
                store.send(.speedButtonTapped)
            }) {
                Text("Speed x\(String(format: "%.1f", store.speed))")
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            .actionSheet(isPresented: Binding(
                get: { store.isShowingSpeedOptions },
                set: { store.send(.setShowSpeedOptions($0)) }
            )) {
                ActionSheet(title: Text("Playback Speed"), buttons: [
                    .default(Text("0.5x")) { store.send(.speedSelected(0.5)) },
                    .default(Text("1.0x")) { store.send(.speedSelected(1.0)) },
                    .default(Text("1.5x")) { store.send(.speedSelected(1.5)) },
                    .default(Text("2.0x")) { store.send(.speedSelected(2.0)) },
                    .cancel()
                ])
            }
        }
    }
    
    private var playerContols: some View {
        HStack {
            Button(action: {
                store.send(.previousButtonTapped)
            }) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 28))
                    .tint(.black)
            }
            
            Button(action: {
                store.send(.backward5SecondsTapped)
            }) {
                Image(systemName: "5.arrow.trianglehead.counterclockwise")
                    .font(.system(size: 32))
                    .tint(.black)
            }
            
            Button(action: {
                store.send(.playPauseButtonTapped)
            }) {
                Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 48))
                    .frame(width: 60, height: 60)
                    .tint(.black)
            }
            
            Button(action: {
                store.send(.forward10SecondsTapped)
            }) {
                Image(systemName: "10.arrow.trianglehead.clockwise")
                    .font(.system(size: 32))
                    .tint(.black)
            }
            
            Button(action: {
                store.send(.nextButtonTapped)
            }) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 28))
                    .tint(.black)
            }
        }
        .padding()
    }
    
    private var bottomMenu: some View {
        HStack {
            
            Spacer()

            HStack {
                
                Button(action: {
                    
                }) {
                    Image(systemName: "headphones")
                        .font(.title)
                        .padding(.horizontal, 5)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 50, height: 50)
                        )
                        .foregroundColor(.white)
                }
                
                Spacer()
               
                Button(action: {
                    
                }) {
                    Image(systemName: "list.bullet")
                        .font(.title)
                        .padding(.horizontal, 5)
                        .foregroundColor(.black)
                }
            }
            .frame(width: 100, height: 50)
            .background(Color.white)
            .cornerRadius(25)
            
            Spacer()
        }
    }
}

private extension ContentView {
    func formatTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func chapterDuration(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Color {
    static let primaryBackground = Color("mainBackground")
}
