#!/bin/bash

echo "Stopping any running server on port 4000..."
PID=$(lsof -t -i:4000)
if [ ! -z "$PID" ]; then
    echo "Killing process $PID"
    kill -9 $PID
fi

echo "Starting server..."
node server.js 