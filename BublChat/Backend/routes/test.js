const express = require('express');
const router = express.Router();
const Conversation = require('../models/Conversation');

// Test route to check if API is working
router.get('/', (req, res) => {
  res.json({ message: 'Test route is working' });
});

// Create a test conversation
router.post('/conversations', async (req, res) => {
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
      // Generate Bubl's response
      await conversation.addMessage({
        sender: 'bubl',
        content: 'Hello! I received your test message. How can I help you today?',
        mediaType: 'text'
      });
    }
    
    res.status(201).json(conversation);
  } catch (error) {
    console.error('Error creating test conversation:', error);
    res.status(500).json({ error: 'Failed to create test conversation', details: error.message });
  }
});

// Get all test conversations
router.get('/conversations', async (req, res) => {
  try {
    const conversations = await Conversation.find({ 
      userId: 'test-user-123',
      status: { $ne: 'deleted' }
    }).sort({ updatedAt: -1 });
    
    res.json(conversations);
  } catch (error) {
    console.error('Error fetching test conversations:', error);
    res.status(500).json({ error: 'Failed to fetch test conversations', details: error.message });
  }
});

// Add a message to a test conversation
router.post('/conversations/:id/messages', async (req, res) => {
  try {
    const { content, mediaType } = req.body;
    
    const conversation = await Conversation.findOne({
      _id: req.params.id,
      userId: 'test-user-123'
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
    
    // Add Bubl's response
    await conversation.addMessage({
      sender: 'bubl',
      content: `I received your test message: "${content}". This is a test response.`,
      mediaType: mediaType || 'text'
    });
    
    res.json(conversation);
  } catch (error) {
    console.error('Error adding message:', error);
    res.status(500).json({ error: 'Failed to add message', details: error.message });
  }
});

module.exports = router; 