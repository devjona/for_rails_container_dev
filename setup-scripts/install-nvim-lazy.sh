#!/bin/bash
set -e

# Installing from : https://github.com/neovim/neovim/releases/tag/v0.11.3

echo "changing to /opt/"
cd /opt

echo "getting Neovim appimage"
wget https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.appimage

echo "makign neovim appimage executable"
chmod u+x nvim-linux-x86_64.appimage

# I don't have sufficient FUSE config; maybe I can fix that later.
echo "extracting image"
./nvim-linux-x86_64.appimage --appimage-extract
