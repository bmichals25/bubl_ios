require('dotenv').config();
const mongoose = require('mongoose');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/bublchat';

console.log('Attempting to connect to MongoDB...');
console.log(`Connection string: ${MONGODB_URI.replace(/\/\/([^:]+):([^@]+)@/, '//***:***@')}`); // Hide credentials

mongoose.connect(MONGODB_URI, { 
  useNewUrlParser: true, 
  useUnifiedTopology: true 
})
.then(() => {
  console.log('✅ MongoDB connection successful!');
  console.log('Database is ready to use.');
  
  // Close the connection after successful test
  mongoose.connection.close();
  console.log('Connection closed.');
})
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
}); 