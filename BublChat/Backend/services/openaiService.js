const OpenAI = require('openai');

// Initialize the OpenAI client with API key from environment variables
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Log a confirmation that OpenAI service is initialized (without exposing the key)
console.log('OpenAI service initialized with API key:', 
  process.env.OPENAI_API_KEY ? 
    `${process.env.OPENAI_API_KEY.substring(0, 10)}...` : 
    'Not found - API calls will fail');

/**
 * Generate a response using the OpenAI API
 * @param {string} prompt - The user's message
 * @param {Array} conversationHistory - Previous messages in the conversation
 * @returns {Promise<string>} The AI-generated response
 */
async function generateResponse(prompt, conversationHistory = []) {
  try {
    // Format the conversation history for the OpenAI API
    const messages = [];
    
    // Add system message to set the AI's personality and behavior
    messages.push({
      role: 'system',
      content: 'You are Bubl, a friendly and empathetic AI companion. You offer thoughtful, personalized conversation while maintaining a positive and supportive tone. You provide concise and relevant responses to the user\'s messages.'
    });
    
    // Add conversation history
    if (conversationHistory && conversationHistory.length > 0) {
      for (const message of conversationHistory) {
        messages.push({
          role: message.sender === 'user' ? 'user' : 'assistant',
          content: message.content
        });
      }
    }
    
    // Add the current user message
    messages.push({
      role: 'user',
      content: prompt
    });
    
    console.log('Calling OpenAI API with message:', prompt.substring(0, 50) + (prompt.length > 50 ? '...' : ''));
    
    // Call the OpenAI API
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: messages,
      max_tokens: 500,
      temperature: 0.7,
    });
    
    // Extract and return the response text
    const response = completion.choices[0].message.content.trim();
    console.log('OpenAI Response (truncated):', response.substring(0, 50) + (response.length > 50 ? '...' : ''));
    
    return response;
  } catch (error) {
    console.error('Error generating AI response:', error);
    throw new Error('Failed to generate AI response');
  }
}

module.exports = {
  generateResponse
}; 