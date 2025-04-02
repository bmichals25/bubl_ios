# BublChat

BublChat is an engaging AI-powered chat application featuring Bubl, a friendly AI character that users can interact with through text, voice, and video.

## Project Structure

```
BublChat/
├── iOS/                   # iOS App (SwiftUI)
│   ├── BublChatApp/       # Main app files
│   │   ├── Core/          # Core services & models
│   │   ├── UI/            # UI components
│   │   ├── AIServices/    # AI integration
│   │   └── Animation/     # Character animation
│   └── Package.swift      # Swift package configuration
├── Backend/               # Node.js Express Server
│   ├── routes/            # API routes
│   ├── models/            # Database models
│   ├── controllers/       # Business logic
│   ├── middleware/        # Custom middleware
│   ├── server.js          # Main server file
│   └── package.json       # Node.js dependencies
└── Documentation/         # Project documentation
    └── BublCharacterProfile.md # Bubl character design
```

## Getting Started

### Prerequisites

- iOS Development: Xcode 14+, Swift 5.5+
- Backend Development: Node.js 16+, MongoDB
- Firebase account for authentication
- OpenAI API key (for Bubl's responses)

### iOS Setup

1. Open the iOS directory in Xcode
2. Install dependencies
3. Configure Firebase credentials
4. Build and run the app

### Backend Setup

1. Navigate to the Backend directory
2. Install dependencies with `npm install`
3. Copy `.env.example` to `.env` and configure environment variables
4. Start the server with `npm run dev`

## Features (MVP)

- User authentication via Firebase
- Text chat with Bubl
- Voice call capability
- Video chat with animated Bubl character
- Conversation history storage
- User profile management

## Development Roadmap

See the [MVP Development Plan](./Documentation/bublchat-mvp-plan.md) for the detailed development roadmap.

## Technical Stack

- Frontend: Swift/SwiftUI (iOS)
- Backend: Node.js with Express
- Database: MongoDB
- Authentication: Firebase
- Real-time Communication: Socket.io, WebRTC
- Natural Language Processing: OpenAI GPT API
- Character Animation: SceneKit/ARKit

## Contributing

Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 