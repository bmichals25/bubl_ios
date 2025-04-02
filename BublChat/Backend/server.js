require('dotenv').config();

// Log the OpenAI API key (partial, for debugging)
console.log('OpenAI API Key from env:', process.env.OPENAI_API_KEY ? 
  `${process.env.OPENAI_API_KEY.substring(0, 10)}...` : 'Not found');

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const morgan = require('morgan');
const helmet = require('helmet');
const http = require('http');
const socketIo = require('socket.io');
const firebaseAdmin = require('firebase-admin');
const openaiService = require('./services/openaiService');

// Initialize Firebase Admin (will need service account later)
try {
  firebaseAdmin.initializeApp({
    credential: firebaseAdmin.credential.applicationDefault()
  });
} catch (error) {
  console.warn('Firebase admin initialization failed:', error.message);
  console.warn('Authentication features will not work until Firebase is properly configured.');
}

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(bodyParser.json());
app.use(morgan('dev'));

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/bublchat';

mongoose.connect(MONGODB_URI, { 
  useNewUrlParser: true, 
  useUnifiedTopology: true 
})
.then(() => console.log('MongoDB connected...'))
.catch(err => console.error('MongoDB connection error:', err));

// Import Routes
const authRoutes = require('./routes/auth');
const conversationRoutes = require('./routes/conversations');
const testRoutes = require('./routes/test');

// Route Middleware
app.use('/api/auth', authRoutes);
app.use('/api/conversations', conversationRoutes);
app.use('/api/test', testRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to BublChat API' });
});

// Socket.io connection handler
io.on('connection', (socket) => {
  console.log('New client connected:', socket.id);
  
  // Store conversation history for this socket connection
  const conversationHistory = [];
  
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
  
  // Handle messages sent via Socket.IO
  socket.on('message', (data) => {
    console.log('Message received via Socket.IO:', data);
    handleMessageAndRespond(socket, data, conversationHistory);
  });
  
  // Handle raw WebSocket messages (for compatibility with native WebSocket clients)
  socket.on('data', (data) => {
    console.log('Raw WebSocket data received:', data);
    
    try {
      // Try to parse the data if it's a string
      if (typeof data === 'string') {
        const jsonData = JSON.parse(data);
        handleMessageAndRespond(socket, jsonData, conversationHistory);
      } else if (Buffer.isBuffer(data)) {
        // Handle binary data if needed
        const stringData = data.toString();
        try {
          const jsonData = JSON.parse(stringData);
          handleMessageAndRespond(socket, jsonData, conversationHistory);
        } catch (e) {
          console.error('Failed to parse buffer data as JSON:', e);
        }
      }
    } catch (error) {
      console.error('Error processing raw WebSocket data:', error);
      // Respond with error
      socket.emit('response', {
        text: 'Sorry, I could not process that message.',
        timestamp: new Date().toISOString()
      });
    }
  });
});

// Handle message processing and response generation
async function handleMessageAndRespond(socket, data, conversationHistory) {
  // Identify what type of data we received
  let messageText = '';
  
  if (typeof data === 'string') {
    messageText = data;
  } else if (data && data.text) {
    messageText = data.text;
  } else if (data && typeof data === 'object') {
    // Try to extract text from an object
    const possibleTextFields = ['text', 'message', 'content', 'input'];
    for (const field of possibleTextFields) {
      if (data[field] && typeof data[field] === 'string') {
        messageText = data[field];
        break;
      }
    }
  }
  
  // If we couldn't extract a message, use a default one
  if (!messageText) {
    messageText = 'Empty message';
  }
  
  console.log('Processed message text:', messageText);
  
  // Add user message to conversation history
  conversationHistory.push({
    sender: 'user',
    content: messageText
  });
  
  // Keep only the latest 10 messages in history to avoid context size issues
  if (conversationHistory.length > 10) {
    conversationHistory.shift();
  }
  
  let responseText;
  
  try {
    // Generate response using OpenAI
    responseText = await openaiService.generateResponse(messageText, conversationHistory);
    
    // Add AI response to conversation history
    conversationHistory.push({
      sender: 'bubl',
      content: responseText
    });
  } catch (error) {
    console.error('Error generating AI response:', error);
    // Fallback responses in case of AI error
    const fallbackResponses = [
      "I'm having a bit of trouble connecting right now. Can we try again?",
      "Sorry, I couldn't process that properly. Could you rephrase?",
      "I'm experiencing a brief hiccup. Let's try again in a moment.",
      "My systems are a bit overwhelmed at the moment. Can you repeat that?",
      "I seem to be having connection issues. Let's try again."
    ];
    responseText = fallbackResponses[Math.floor(Math.random() * fallbackResponses.length)];
  }
  
  // Create response object
  const response = {
    text: responseText,
    timestamp: new Date().toISOString()
  };
  
  // Send response back to client
  console.log('Sending response:', response);
  socket.emit('response', response);
  
  // Also send raw JSON for WebSocket clients that don't use Socket.IO
  socket.send(JSON.stringify(response));
}

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: true,
    message: 'Internal Server Error'
  });
});

// Start the server
const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  
  // Log all registered routes
  console.log('\nRegistered Routes:');
  app._router.stack.forEach(middleware => {
    if(middleware.route) { // routes registered directly on the app
      console.log(`${middleware.route.path}`);
    } else if(middleware.name === 'router') { // router middleware
      middleware.handle.stack.forEach(handler => {
        if(handler.route) {
          const path = handler.route.path;
          const methods = Object.keys(handler.route.methods).join(', ').toUpperCase();
          console.log(`${methods} ${path}`);
        }
      });
    }
  });
}); 