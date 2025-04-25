#!/bin/bash

# Script to send notifications to AlMoslim app users

# Change to the script directory
cd "$(dirname "$0")"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install it from https://nodejs.org/"
    exit 1
fi

# Check if serviceAccountKey.json exists
if [ ! -f "./serviceAccountKey.json" ]; then
    echo "Error: serviceAccountKey.json not found!"
    echo "Please download your Firebase service account key and save it as serviceAccountKey.json in this directory."
    exit 1
fi

# Check if firebase-admin is installed
if ! npm list firebase-admin &> /dev/null; then
    echo "Installing firebase-admin..."
    npm install firebase-admin
fi

# Send notifications
echo "Sending notifications to AlMoslim app users..."
node send_notifications.js

echo "Done!"
