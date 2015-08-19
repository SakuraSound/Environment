#!/bin/bash

TODAY=$(date +%Y-%m-%d)

# CHANGE THIS if needed
HOMEBREW_UPDATE_ON_REFRESH=false

PIP_UPDATE_ON_REFRESH=false

ATOM_UPDATE_ON_REFRESH=false


bold=$(tput bold)
normal=$(tput sgr0)

clear

# Check to see if brew is installed
which -s brew

if [[ $? != 0 ]] ; then
    # We want to install homebrew
    echo "${bold}Installing Homebrew...${normal}"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    brew install cask
    # With homebrew installed, we will look for a brewfile to install from
    echo "${bold}Checking for Brewfile...${normal}"
    if [[ -f "$ENVIRONMENT_PATH/Brewfile" ]] ; then

        # Found a Brewfile! Let's install stuff through it!
        echo "${bold}Using Homebrew to install from Brewfile...${normal}"
        while read -r LINE; do
             brew install "$LINE";
        done < "$ENVIRONMENT_PATH/Brewfile";

    else
        echo "${bold}No Brewfile found. Skipping package install${normal}"
    fi

    echo "${bold}Checking for Caskfile...${normal}"
    if [[ -f "$ENVIRONMENT_PATH/Caskfile" ]] ; then

        # Found a Brewfile! Let's install stuff through it!
        echo "${bold}Using Cask to install from Brewfile...${normal}"
        while read -r LINE; do
            brew cask install "$LINE";
        done < "$ENVIRONMENT_PATH/Caskfile";

    else
        echo "${bold}No Caskfile found. Skipping application install${normal}"
    fi

    # Install all python requirements using requirements.txt
    if [[ -f "$ENVIRONMENT_PATH/requirements.txt" ]] ; then
        echo "${bold}Installing python dependencies...${normal}"
        pip install -r "$ENVIRONMENT_PATH/requirements.txt"
    else
        echo "${bold}No requirements.txt file. Skipping install of python dependencies${normal}"
    fi

    #Need to check for atom
    which -s atom

    if  [[ $? != 0 ]] ; then

        # Install atom and add packages
        echo "${bold}Installing atom...${normal}"
        brew cask install atom

        if [[ -f "$ENVIRONMENT_PATH/Atomfile" ]] ; then
            echo "${bold}Installing packages from your Atomfile...${normal}"
            apm install --packages-file "$ENVIRONMENT_PATH/Atomfile"
        fi
    fi


else
    # If we havent run an update today, lets run one!
    if [[ $TODAY > $LAST_UPDATE || -z "$LAST_UPDATE" ]] ; then
        # Homebrew updates
        if $HOMEBREW_UPDATE_ON_REFRESH; then
            # Let us update homebrew
            echo "${bold}Running brew update...${normal}"
            brew update
            inventory-brew

            brew cask update
            inventory-cask

        else
            echo "${bold}Checking for outdated Homebrew packages...${normal}"
            brew outdated
            inventory-brew
            inventory-cask
        fi

        # PIP updates
        if $PIP_UPDATE_ON_REFRESH; then
            echo "${bold}Running pip install to pull new packages...${normal}"
            pip install --upgrade
            inventory-pip
        else
            echo "${bold}Checking for outdated Python packages...${normal}"
            pip list --outdated
            inventory-pip
        fi

        # APM updates
        if $ATOM_UPDATE_ON_REFRESH; then
            echo "${bold}Updating Atom packages...${normal}"
            apm update
            inventory-atom
        else
            echo "${bold}Checking for outdated Atom packages...${normal}"
            apm outdated
            inventory-atom
        fi
        export LAST_UPDATE=TODAY
    fi
fi

source /usr/local/etc/bash_completion.d/git-completion.bash

if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    . "$(brew --prefix)/etc/bash_completion"
fi
