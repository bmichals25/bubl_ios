require('dotenv').config();
const mongoose = require('mongoose');

// Import the Conversation model
const Conversation = require('./models/Conversation');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/bublchat';

console.log('Attempting to connect to MongoDB...');
console.log(`Connection string: ${MONGODB_URI.replace(/\/\/([^:]+):([^@]+)@/, '//***:***@')}`);

async function testGetConversations() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI, { 
      useNewUrlParser: true, 
      useUnifiedTopology: true 
    });
    
    console.log('✅ MongoDB connection successful!');
    
    // Retrieve all conversations
    const conversations = await Conversation.find({}).sort({ updatedAt: -1 }).limit(10);
    console.log(`Found ${conversations.length} conversations in the database.`);
    
    if (conversations.length === 0) {
      console.log('No conversations found. Try running test-create-convo.js first.');
    } else {
      // Display details for each conversation
      conversations.forEach((conversation, index) => {
        console.log(`\nConversation #${index + 1}:`);
        console.log('- ID:', conversation._id);
        console.log('- Title:', conversation.title);
        console.log('- User ID:', conversation.userId);
        console.log('- Created At:', conversation.createdAt);
        console.log('- Messages:', conversation.messages.length);
        
        // Show first few messages
        if (conversation.messages.length > 0) {
          console.log('\nSample messages:');
          conversation.messages.slice(0, 3).forEach((msg, msgIndex) => {
            console.log(`[${msgIndex + 1}] ${msg.sender}: ${msg.content}`);
          });
          
          if (conversation.messages.length > 3) {
            console.log(`... and ${conversation.messages.length - 3} more messages`);
          }
        }
      });
    }
    
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
testGetConversations(); 