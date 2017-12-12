#!/usr/bin/env bash

DOT_FILES_REPO=git@github.com:victorpantoja/dotfiles.git
BASH_FILE=${HOME}/.bashrc
PROJECT_HOME=${HOME}/projects
DOTFILES=${PROJECT_HOME}/dotfiles

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

install_python() {
    if ! check_software python; then
        install_debian python
        install_debian python-pip
    fi
}

install_ruby() {
#    if ! check_software rvm; then
#        echo "Installing RVM"
#
#        sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
#        curl -sSL https://get.rvm.io | sudo bash -s stable --autolibs=read-fail
#        sudo usermod -a -G rvm `whoami`
#
#        echo "Execute steps above and run this script again"
#    fi

    echo "Installing ruby"
    sudo apt install ruby
#    sudo apt-get -y --allow-change-held-packages install gawk zlib1g-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgmp-dev libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev libgmp-dev libreadline6-dev libssl-dev
#    rvm install ruby
#    rvm --default use ruby
}

install_venv() {
    install_python

    if ! check_software virtualenvwrapper.sh; then
        install_pip virtualenvwrapper

        VENV_PATH=$(which virtualenvwrapper.sh)

        VIRTUALENV=$'
    #virtualenvwrapper
    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/projects
    source '
        VIRTUALENV="$VIRTUALENV $VENV_PATH"

        grep -q -F '#virtualenvwrapper' ${BASH_FILE} || echo "${VIRTUALENV}" >> ${BASH_FILE}

        echo "Please run:"
        echo "source ${BASH_FILE}"
    fi
}

pre_run() {
    echo "Installing base libs"
    sudo apt-get update
    sudo apt-get -y --allow-change-held-packages install vim htop curl dialog
}

#pre_run

cmd=(dialog --separate-output --checklist "Software to be installed:" 22 76 16)
options=(1 "Python" off
         2 "Virtualenv" off
         3 "Chrome" off
         4 "git" off
         5 "Configure dot files" off,
         6 "tmux" off,
         7 "tmuxinator" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in ${choices}
do
    case ${choice} in
        1)
            install_python
            ;;
        2)
            install_venv
            ;;
        3)
            if ! check_software google-chrome; then
                wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
                echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
                sudo apt-get update
                install_debian google-chrome-stable
            fi
            ;;
        4)
            install_debian git
            ;;
        5)
            if ! check_software git; then
                install_debian git

                git config --global user.email "victor.pantoja@gmail.com"
                git config --global user.name "Victor Pantoja"
            fi

            if [ ! -e ${DOTFILES} ]; then
                git clone ${DOT_FILES_REPO} ${DOTFILES}
            fi

            DOT_CONFIGURATION=$'
#bash configuration
source'
    DOT_CONFIGURATION="$DOT_CONFIGURATION ${PROJECT_HOME}/dotfiles/.bashrc"

            grep -q -F '#bash configuration' ${BASH_FILE} || echo "${DOT_CONFIGURATION}" >> ${BASH_FILE}

            echo "Please run:"
            echo "source ${BASH_FILE}"

            ;;

         6)
            if ! check_software ruby; then
                install_ruby
            fi

            ln -s ${DOTFILES}/tmux.conf ${HOME}/.tmux.conf
         ;;

         7)
            if ! check_software tmux; then
                install tmux
            fi

            if ! check_software tmuxinator; then
                sudo gem install tmuxinator
            fi

            TMUXINATOR_CONFIGURATION=$'
#tmuxinator
source'
            TMUXINATOR_CONFIGURATION="$TMUXINATOR_CONFIGURATION ${DOTFILES}/tmuxinator.bash"

            grep -q -F '#tmuxinator' ${BASH_FILE} || echo "${TMUXINATOR_CONFIGURATION}" >> ${BASH_FILE}

            echo "Please run:"
            echo "source ${BASH_FILE}"
         ;;
    esac
done