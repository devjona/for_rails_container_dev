#!/bin/bash
# Taken from https://nodejs.org/en/download
# I'm not sure if we have to do any $PATH config stuff, but we'll cross that bridge if we come to it.

# Download and install nvm:
echo "Installing NVM…"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
echo "Installing Node version 22:"
nvm install 22

# Verify the Node.js version:
echo "Node version is:"
node -v # Should print "v22.17.1".

echo "Node version via NVM is:"
nvm current # Should print "v22.17.1".

# Verify npm version:
echo "NPM version is:"
npm -v # Should print "10.9.2".

echo "Installing yarn…"
npm i -g yarn

echo "Yarn version is:"
yarn -v
