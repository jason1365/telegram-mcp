#!/bin/bash

# Telegram MCP Session String Generator
# Uses Docker with mounted directory and existing session generator script

echo "🔐 Telegram MCP Session String Generator"
echo "======================================="
echo
echo "This will generate a session string using the existing session_string_generator.py"
echo "You'll need:"
echo "  - Your API_ID and API_HASH from https://my.telegram.org/apps"
echo "  - Your phone number (with country code)"
echo "  - Access to your Telegram app for verification code"
echo
echo "Press Enter to continue, or Ctrl+C to cancel..."
read -r

echo "Starting Docker container with mounted directory..."
docker run -it --rm -v "$(pwd)":/app -w /app python:3.13-alpine sh -c "
    pip install telethon python-dotenv > /dev/null 2>&1 && 
    python session_string_generator.py
"

echo
echo "🎉 Session generation complete!"
echo "The .env file should now be updated with your session string."