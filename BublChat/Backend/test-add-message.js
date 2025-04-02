require('dotenv').config();
const mongoose = require('mongoose');
const readline = require('readline');

// Import the Conversation model
const Conversation = require('./models/Conversation');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/bublchat';

console.log('Attempting to connect to MongoDB...');
console.log(`Connection string: ${MONGODB_URI.replace(/\/\/([^:]+):([^@]+)@/, '//***:***@')}`);

// Create readline interface
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

async function testAddMessage() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI, { 
      useNewUrlParser: true, 
      useUnifiedTopology: true 
    });
    
    console.log('✅ MongoDB connection successful!');
    
    // Retrieve recent conversations
    const conversations = await Conversation.find({}).sort({ updatedAt: -1 }).limit(5);
    
    if (conversations.length === 0) {
      console.log('No conversations found. Try running test-create-convo.js first.');
      return;
    }
    
    // Display available conversations
    console.log('Available conversations:');
    conversations.forEach((convo, index) => {
      console.log(`[${index + 1}] ID: ${convo._id}, Title: ${convo.title}, Messages: ${convo.messages.length}`);
    });
    
    // Use the first conversation
    const selectedConversation = conversations[0];
    console.log(`\nUsing conversation: ${selectedConversation._id} - ${selectedConversation.title}`);
    
    // Add a user message
    const userMessage = "How are you today, Bubl? This is a follow-up test message.";
    await selectedConversation.addMessage({
      sender: 'user',
      content: userMessage,
      mediaType: 'text'
    });
    console.log(`✅ Added user message: "${userMessage}"`);
    
    // Add Bubl's response
    const bublResponse = "I'm doing great, thank you for asking! I'm just a test response, but in the full app I'll have more personality.";
    await selectedConversation.addMessage({
      sender: 'bubl',
      content: bublResponse,
      mediaType: 'text'
    });
    console.log(`✅ Added Bubl response: "${bublResponse}"`);
    
    // Retrieve the updated conversation
    const updatedConversation = await Conversation.findById(selectedConversation._id);
    
    console.log(`\nConversation now has ${updatedConversation.messages.length} messages:`);
    updatedConversation.messages.forEach((msg, index) => {
      console.log(`[${index + 1}] ${msg.sender}: ${msg.content}`);
    });
    
    console.log('\n✅ Test completed successfully!');
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    // Close the MongoDB connection
    await mongoose.connection.close();
    console.log('MongoDB connection closed.');
    rl.close();
  }
}

// Run the test function
testAddMessage(); 