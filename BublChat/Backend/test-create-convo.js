require('dotenv').config();
const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// Import the Conversation model
const Conversation = require('./models/Conversation');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/bublchat';

console.log('Attempting to connect to MongoDB...');
console.log(`Connection string: ${MONGODB_URI.replace(/\/\/([^:]+):([^@]+)@/, '//***:***@')}`);

async function testCreateConversation() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI, { 
      useNewUrlParser: true, 
      useUnifiedTopology: true 
    });
    
    console.log('✅ MongoDB connection successful!');
    
    // Create a test user ID
    const testUserId = 'test-' + uuidv4();
    console.log(`Creating test conversation for user: ${testUserId}`);
    
    // Create a new conversation
    const conversation = new Conversation({
      userId: testUserId,
      title: 'Test Conversation',
      messages: [{
        sender: 'user',
        content: 'Hello Bubl! This is a test message.',
        mediaType: 'text'
      }]
    });
    
    // Save the conversation
    await conversation.save();
    console.log('✅ Conversation created successfully with ID:', conversation._id);
    
    // Add a response from Bubl
    await conversation.addMessage({
      sender: 'bubl',
      content: 'Hello! I received your test message. How can I help you today?',
      mediaType: 'text'
    });
    console.log('✅ Bubl response added successfully');
    
    // Retrieve the updated conversation
    const updatedConversation = await Conversation.findById(conversation._id);
    console.log('\nConversation Details:');
    console.log('- ID:', updatedConversation._id);
    console.log('- Title:', updatedConversation.title);
    console.log('- User ID:', updatedConversation.userId);
    console.log('- Created At:', updatedConversation.createdAt);
    console.log('- Messages:', updatedConversation.messages.length);
    
    console.log('\nMessage contents:');
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
  }
}

// Run the test function
testCreateConversation(); 