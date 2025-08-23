#!/bin/bash
set -e

# Installing from : https://github.com/neovim/neovim/releases/tag/v0.11.3

echo "Changing to /opt/…"
cd /opt

echo "Getting Neovim appimage…"
wget https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.appimage

echo "Making Neovim appimage executable…"
chmod u+x nvim-linux-x86_64.appimage

# I don't have sufficient FUSE config; maybe I can fix that later.
echo "Extracting image…"
./nvim-linux-x86_64.appimage --appimage-extract

echo "Adding Neovim to PATH…"
echo "export PATH=$PATH:/opt/squashfs-root/usr/bin/ " >>/root/.bashrc
