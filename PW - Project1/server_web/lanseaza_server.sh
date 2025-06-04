#!/bin/bash

# Script to launch the Python HTTP server
# chmod +x lanseaza_server.sh
# Usage: ./lanseaza_server.sh

# Check if the server is already running
if pgrep -f "server.py" > /dev/null
then
    echo "Server is already running!"
    exit 1
fi

# Start the server in the background
python3 server_web.py &

# Get the PID of the server process
SERVER_PID=$!

# Save the PID to a file for later reference
echo $SERVER_PID > server.pid

echo "Server started with PID: $SERVER_PID"
echo "Access the server at: http://localhost:5678"