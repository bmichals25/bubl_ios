const express = require('express');
const router = express.Router();
const firebaseAdmin = require('firebase-admin');
const Conversation = require('../models/Conversation');
const openaiService = require('../services/openaiService');

// Middleware to verify Firebase token
const verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: No token provided' });
  }
  
  const token = authHeader.split(' ')[1];
  
  try {
    const decodedToken = await firebaseAdmin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(403).json({ error: 'Forbidden: Invalid token' });
  }
};

// TEST ROUTE - No auth required (for testing only)
router.post('/test', async (req, res) => {
  try {
    const { title, initialMessage } = req.body;
    
    const conversation = new Conversation({
      userId: 'test-user-123', // Hardcoded test user ID
      title: title || 'Test Conversation',
      messages: initialMessage ? [{
        sender: 'user',
        content: initialMessage,
        mediaType: 'text'
      }] : []
    });
    
    await conversation.save();
    
    if (initialMessage) {
      try {
        // Generate AI response using OpenAI
        const aiResponse = await openaiService.generateResponse(initialMessage, []);
        
        // Add Bubl's response
        await conversation.addMessage({
          sender: 'bubl',
          content: aiResponse,
          mediaType: 'text'
        });
      } catch (error) {
        console.error('Error generating AI response for test route:', error);
        // Fallback response in case of AI error
        await conversation.addMessage({
          sender: 'bubl',
          content: "I'm having trouble connecting right now. Please try again in a moment.",
          mediaType: 'text'
        });
      }
    }
    
    res.status(201).json(conversation);
  } catch (error) {
    console.error('Error creating test conversation:', error);
    res.status(500).json({ error: 'Failed to create test conversation' });
  }
});

// TEST ROUTE - Get all test conversations
router.get('/test', async (req, res) => {
  try {
    const conversations = await Conversation.find({ 
      userId: 'test-user-123',
      status: { $ne: 'deleted' }
    }).sort({ updatedAt: -1 });
    
    res.json(conversations);
  } catch (error) {
    console.error('Error fetching test conversations:', error);
    res.status(500).json({ error: 'Failed to fetch test conversations' });
  }
});

// Get all conversations for a user
router.get('/', verifyToken, async (req, res) => {
  try {
    const conversations = await Conversation.find({ 
      userId: req.user.uid,
      status: { $ne: 'deleted' }
    }).sort({ updatedAt: -1 });
    
    res.json(conversations);
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ error: 'Failed to fetch conversations' });
  }
});

// Get a single conversation by ID
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const conversation = await Conversation.findOne({
      _id: req.params.id,
      userId: req.user.uid,
      status: { $ne: 'deleted' }
    });
    
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }
    
    res.json(conversation);
  } catch (error) {
    console.error('Error fetching conversation:', error);
    res.status(500).json({ error: 'Failed to fetch conversation' });
  }
});

// Create a new conversation
router.post('/', verifyToken, async (req, res) => {
  try {
    const { title, initialMessage } = req.body;
    
    const conversation = new Conversation({
      userId: req.user.uid,
      title: title || 'New Conversation',
      messages: initialMessage ? [{
        sender: 'user',
        content: initialMessage,
        mediaType: 'text'
      }] : []
    });
    
    await conversation.save();
    
    if (initialMessage) {
      try {
        // Generate AI response using OpenAI
        const aiResponse = await openaiService.generateResponse(initialMessage, []);
        
        // Add Bubl's response
        await conversation.addMessage({
          sender: 'bubl',
          content: aiResponse,
          mediaType: 'text'
        });
      } catch (error) {
        console.error('Error generating AI response:', error);
        // Fallback response in case of AI error
        await conversation.addMessage({
          sender: 'bubl',
          content: "I'm having trouble connecting right now. Please try again in a moment.",
          mediaType: 'text'
        });
      }
    }
    
    res.status(201).json(conversation);
  } catch (error) {
    console.error('Error creating conversation:', error);
    res.status(500).json({ error: 'Failed to create conversation' });
  }
});

// Add a message to a conversation
router.post('/:id/messages', verifyToken, async (req, res) => {
  try {
    const { content, mediaType } = req.body;
    
    const conversation = await Conversation.findOne({
      _id: req.params.id,
      userId: req.user.uid,
      status: 'active'
    });
    
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }
    
    // Add user message
    await conversation.addMessage({
      sender: 'user',
      content,
      mediaType: mediaType || 'text'
    });
    
    try {
      // Get conversation history (last 10 messages for context)
      const conversationHistory = conversation.messages.slice(-10);
      
      // Generate AI response using OpenAI
      const aiResponse = await openaiService.generateResponse(content, conversationHistory);
      
      // Add Bubl's response
      await conversation.addMessage({
        sender: 'bubl',
        content: aiResponse,
        mediaType: 'text'
      });
    } catch (error) {
      console.error('Error generating AI response:', error);
      // Fallback response in case of AI error
      await conversation.addMessage({
        sender: 'bubl',
        content: "I'm having trouble connecting right now. Please try again in a moment.",
        mediaType: 'text'
      });
    }
    
    res.json(conversation);
  } catch (error) {
    console.error('Error adding message:', error);
    res.status(500).json({ error: 'Failed to add message' });
  }
});

// Update conversation status (archive/delete)
router.patch('/:id', verifyToken, async (req, res) => {
  try {
    const { status, title } = req.body;
    
    const updateData = {};
    if (status) updateData.status = status;
    if (title) updateData.title = title;
    
    const conversation = await Conversation.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.uid },
      updateData,
      { new: true }
    );
    
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }
    
    res.json(conversation);
  } catch (error) {
    console.error('Error updating conversation:', error);
    res.status(500).json({ error: 'Failed to update conversation' });
  }
});

// TEST ROUTE - Add message to test conversation (no auth required)
router.post('/test/:id/messages', async (req, res) => {
  try {
    const { content, mediaType } = req.body;
    
    const conversation = await Conversation.findOne({
      _id: req.params.id,
      userId: 'test-user-123',
      status: 'active'
    });
    
    if (!conversation) {
      return res.status(404).json({ error: 'Test conversation not found' });
    }
    
    // Add user message
    await conversation.addMessage({
      sender: 'user',
      content,
      mediaType: mediaType || 'text'
    });
    
    try {
      // Get conversation history (last 10 messages for context)
      const conversationHistory = conversation.messages.slice(-10);
      
      // Generate AI response using OpenAI
      const aiResponse = await openaiService.generateResponse(content, conversationHistory);
      
      // Add Bubl's response
      await conversation.addMessage({
        sender: 'bubl',
        content: aiResponse,
        mediaType: 'text'
      });
    } catch (error) {
      console.error('Error generating AI response for test message:', error);
      // Fallback response in case of AI error
      await conversation.addMessage({
        sender: 'bubl',
        content: "I'm having trouble connecting right now. Please try again in a moment.",
        mediaType: 'text'
      });
    }
    
    res.json(conversation);
  } catch (error) {
    console.error('Error adding test message:', error);
    res.status(500).json({ error: 'Failed to add test message' });
  }
});

module.exports = router; 