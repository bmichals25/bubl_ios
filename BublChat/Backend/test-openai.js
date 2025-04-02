// Explicitly load dotenv at the very beginning
const dotenv = require('dotenv');
const result = dotenv.config();

if (result.error) {
  console.error('Error loading .env file:', result.error);
} else {
  console.log('.env file loaded successfully');
}

const OpenAI = require('openai');

// Check if the API key is loaded from .env
console.log('API Key from env:', process.env.OPENAI_API_KEY ? 
  `${process.env.OPENAI_API_KEY.substring(0, 10)}...` : 'Not found');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function testOpenAI() {
  try {
    console.log('Testing OpenAI connection...');
    
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are a helpful AI assistant.'
        },
        {
          role: 'user',
          content: 'Hello, how are you?'
        }
      ],
      max_tokens: 50,
    });
    
    console.log('OpenAI Response:', completion.choices[0].message);
    console.log('Connection test successful!');
  } catch (error) {
    console.error('OpenAI Connection Error:', error);
  }
}

testOpenAI(); 