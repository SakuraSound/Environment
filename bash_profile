#!/bin/bash

# Setup environment path
export ENVIRONMENT_PATH=/Users/SakuraSound/Environment

source "$ENVIRONMENT_PATH/exports"

# Import user defined functions
source "$ENVIRONMENT_PATH/functions"

# Import environment aliases
source "$ENVIRONMENT_PATH/aliases"

# Initialization script (in case of new environment)
source "$ENVIRONMENT_PATH/bootstrap.sh"


# Import colorized terminal settings
source "$ENVIRONMENT_PATH/colorized"

# Bring in osx specific inputrc settings
bind -f "$ENVIRONMENT_PATH/inputrc"

# Print out random banner 
# source "$ENVIRONMENT_PATH/splash"
