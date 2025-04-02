#!/bin/bash

# Make sure to set OPENAI_API_KEY in your environment or add it here
# export OPENAI_API_KEY="your_api_key_here"

# Kill any existing Node.js processes running on port 4000
echo "Stopping any existing server processes..."
lsof -ti :4000 | xargs kill -9 2>/dev/null || true

# Start the server with environment variables
node server.js 