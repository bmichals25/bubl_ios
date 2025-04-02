# Bubl iOS Chat App

A SwiftUI-based chat application that connects to a Node.js backend with AI capabilities.

## Features

- Real-time chat using WebSockets
- Integration with OpenAI for AI-powered responses
- SwiftUI interface for iOS
- MongoDB for conversation storage

## Structure

- `/BublChat/iOS/BublChatApp` - iOS SwiftUI App
- `/BublChat/Backend` - Node.js backend with Express and Socket.io

## Setup

### iOS App
1. Open the BublChatApp.xcodeproj in Xcode
2. Build and run the app on a simulator or device

### Backend
1. Navigate to the Backend directory
2. Install dependencies: `npm install`
3. Set up environment variables in `.env` file
4. Start the server: `node server.js`

## Environment Variables

The backend requires the following environment variables:
- `OPENAI_API_KEY` - Your OpenAI API key
- `MONGODB_URI` - MongoDB connection string

## License

MIT 