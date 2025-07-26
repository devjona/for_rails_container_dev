#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Define variables
source "$SCRIPT_DIR/vars.sh"

# Call the rest
source "$SCRIPT_DIR/two.sh"
source "$SCRIPT_DIR/three.sh"
source "$SCRIPT_DIR/four.sh"
