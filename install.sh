#!/usr/bin/env bash

install_debian() {
    echo "Installing ${1}"
    sudo apt-get -y --allow-change-held-packages install $1
}

install_pip() {
    echo "Installing ${1}"
    sudo pip install $1
}

check_software() {
    echo "Checking ${1}"
    if hash ${1} 2>/dev/null; then
        echo "${1} already installed."
        return 0
    else
        return 1
    fi
}

echo "Installing base libs"
sudo apt-get update
sudo apt-get -y --allow-change-held-packages install vim htop python-dev python-pip

BASH_FILE="~/.bashrc"
#BASH_FILE="teste.sh"

if ! check_software virtualenvwrapper.sh; then
    install_pip virtualenvwrapper

    VENV_PATH=$(which virtualenvwrapper.sh)

    VIRTUALENV=$'#virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Documents/projects
source '
    VIRTUALENV="$VIRTUALENV $VENV_PATH"

    grep -q -F '#virtualenvwrapper' ${BASH_FILE} || echo "${VIRTUALENV}" >> ${BASH_FILE}
fi

DOT_CONFIGURATION=$'#bash configuration
source'
DOT_CONFIGURATION="$DOT_CONFIGURATION $PWD/.bashrc"

grep -q -F '#bash configuration' ${BASH_FILE} || echo "${DOT_CONFIGURATION}" >> ${BASH_FILE}
