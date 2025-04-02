require('dotenv').config();
const OpenAI = require('openai');

// Check environment variables
console.log('Environment check:');
console.log(`NODE_ENV: ${process.env.NODE_ENV}`);
console.log(`OPENAI_API_KEY: ${process.env.OPENAI_API_KEY ? 
  `${process.env.OPENAI_API_KEY.substring(0, 10)}...` : 'NOT FOUND'}`);

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Test the API
async function testOpenAI() {
  try {
    console.log('\nTesting OpenAI connection...');
    
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are a helpful assistant.'
        },
        {
          role: 'user',
          content: 'Say "Hello, this is a test of the OpenAI API!"'
        }
      ],
      max_tokens: 50,
    });
    
    console.log('\nAPI Response:');
    console.log(completion.choices[0].message);
    console.log('\nConnection test SUCCESSFUL! ✅');
    
    process.exit(0);
  } catch (error) {
    console.error('\nOpenAI Connection Error:', error);
    console.error('\nConnection test FAILED! ❌');
    
    // Suggest fix
    console.log('\nTo fix this issue:');
    console.log('1. Make sure your .env file contains the correct OPENAI_API_KEY value');
    console.log('2. Or run the server with the API key explicitly set:');
    console.log('   export OPENAI_API_KEY="your-api-key-here" && node server.js');
    
    process.exit(1);
  }
}

testOpenAI(); 