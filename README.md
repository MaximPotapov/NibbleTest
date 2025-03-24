
```markdown
# Nibble

## Summary
Nibble implements most of the required app functionality, delivering a smooth user experience. While the core features work effectively, the app's architecture could be improved, as there are several places where a single action triggers multiple calls. The app has been checked for memory leaks and consumption using profiling instruments, ensuring stability and performance.

## App Description
Nibble is a test assignment for an iOS Engineer position, aimed at creating a lightweight version of the Headway app, focusing specifically on the book audio player feature. This application allows users to listen to audio summaries of books seamlessly.

## Required Functionality
The application includes the following features:
- **Play/Pause Audio:** Users can play or pause the audio playback.
- **Navigate Between Summaries:** Users can switch between different sections of the summary, such as chapters.
- **Adjust Playback Speed:** Users can modify the speed of the audio playback.
- **Seek Forward/Backward:** Users can rewind or fast-forward the audio by a specified time interval.

## Technical Requirements

### Stack
- **SwiftUI:** For creating the user interface.
- **Swift Concurrency:** For asynchronous programming.
- **TCA (The Composable Architecture):** For building a flexible architecture.

### Dependencies
- **Swift Composable Architecture:** v1.17.0

### Deployment Target
- **iOS:** 17.6

## UI Approach
The user interface is designed using native UI elements to ensure that the app looks intuitive and simple for users.

## UX Approach
The application consists of a single screen with an audio player, allowing users to easily access and control their audio summaries.

## Architecture Approach
The application leverages TCA for the view and feature management of the screen. It includes:
- **LiveAudioPlayer Provider:** An implementation of `AVAudioPlayer` to handle audio playback. AVAudioPlayer was chosen for its simplicity and effectiveness in managing audio playback.
- **BookDataProvider:** A provider that fetches book data from a local JSON file. Since there is no external API, the book data is stored in a local JSON file and parsed accordingly.

## Potential App Improvements
- Add a feature to select a specific chapter from a list of all chapters.
- Implement an option to play audio when the device is locked or when the app is in the background.

```

