const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  sender: {
    type: String,
    enum: ['user', 'bubl'],
    required: true
  },
  content: {
    type: String,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  mediaType: {
    type: String,
    enum: ['text', 'voice', 'video'],
    default: 'text'
  },
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: {}
  }
});

const ConversationSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  title: {
    type: String,
    default: 'New Conversation'
  },
  messages: [MessageSchema],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  settings: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: {}
  },
  status: {
    type: String,
    enum: ['active', 'archived', 'deleted'],
    default: 'active'
  }
});

// Update the updatedAt field on save
ConversationSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Method to add a message to the conversation
ConversationSchema.methods.addMessage = function(messageData) {
  this.messages.push(messageData);
  this.updatedAt = Date.now();
  return this.save();
};

module.exports = mongoose.model('Conversation', ConversationSchema); 