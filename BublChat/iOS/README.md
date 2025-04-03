# BublChat iOS App

A SwiftUI-based iOS application for interacting with the Bubl AI assistant through text, voice, and video.

## Features

- **Home Selection Screen**: Choose between Text, Voice, and Video chat modes
- **Text Chat**: Real-time chat conversations with Bubl
- **Voice Chat**: Send voice messages and get responses
- **Video Chat**: Video conferencing with the Bubl avatar
- **Animated Bubl**: Responsive avatar with different emotions
- **Settings**: Account management and app information

## Getting Started

1. Open `BublChatApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the app (⌘+R)

## Project Structure

- `/UI`: Contains all the UI components and screens
  - `HomeSelectionView.swift`: Main selection screen with options for interaction modes
  - `TextChat/`: Text chat implementation
  - `VoiceCall/`: Voice chat components
  - `VideoChat/`: Video chat components
- `/Core`: Contains core functionality and services
  - `Models.swift`: Data models
  - `APIClient.swift`: API communication
  - `WebSocketManager.swift`: Real-time communication
- `BublAnimationView.swift`: The animated Bubl avatar with emotional states

## Implementation Notes

- The app uses a combination of REST API calls and WebSockets for communication
- Firebase is used for authentication
- The backend server is expected to run on `localhost:4000` for development

## Screenshots

- Home Selection Screen: Choose between Text, Voice, and Video chat
- Text Chat: Conversation with animated Bubl avatar
- Voice Chat: Send voice messages to Bubl
- Video Chat: Video call with Bubl

## Next Steps

1. Implement actual voice recognition and text-to-speech
2. Complete the video chat functionality
3. Add offline message support
4. Enhance the animation and emotional responses 