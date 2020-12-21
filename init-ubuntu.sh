#!/usr/bin/env bash

# Author: Yihsiu
# Reference:
#    https://stackoverflow.com/questions/44106842/case-insensitive-regex-in-bash

if [ -z $SHELL ]; then
    echo "Does not support your shell. Use bash instead."
    exit 1
fi

if [ $EUID -ne 0 ]; then
    SUDO=sudo
fi

main() {
    install_softwares
    setup_git_config
    targets="bashrc" # cdecd tmux.conf screenrc"
    backup_config_files "$targets vimrc" 
    setup_bashrc $targets
    setup_vim
}

install_softwares() {
    softwares="git vim exuberant-ctags tmux screen htop silversearcher-ag build-essential "
    softwares+="powerline fonts-powerline"

    if ! $SUDO apt update; then
	echo "Fail to update. Stop."
    fi

    if ! $SUDO apt upgrade; then
	echo "Fail to upgrade. Stop."
    fi

    $SUDO apt install -y linux-headers-$(uname -r)

    if ! $SUDO apt install -y $softwares; then
        echo "Fail to install softwares. Stop."
        exit 1
    fi
}

setup_git_config() {
    git config --global user.name "Yihsiu Chen"
    git config --global user.email "yihsiu.chen@icloud.com"
    printf "\n"
    read -p "Please enter your git user name. (Yihsiu Chen): " username
    if [ -n "$username" ]; then
        git config --global user.name "$username"
    fi
    read -p "Please enter your git user email. (yihsiu.chen@icloud.com): " email
    if [ -n "$email" ]; then
        git config --global user.email "$email"
    fi
     
    git config --global core.editor vim
    git config --global credential.helper cache

    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.ss stash
    git config --global alias.sl 'stash list'
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'

    printf "\n"
    git config -l
    printf "\n"
}

backup_config_files() {
    timestamp=$(date +%s)

    for f in $@; do
        fpath=$HOME/.$f
        if [ -h "$fpath" ]; then
            echo "Remove $fpath ($(stat --format=%F $fpath))"
            rm $fpath
        elif [ -e "$fpath" ]; then
            shopt -s nocasematch
            read -p "Do you want to backup $fpath? (y/N): " backup
            if [[ "$backup" =~ ^y(es)?$ ]]; then
                new_fpath=$fpath.bak.$timestamp
                mv $fpath $new_fpath
                echo "Backup $fpath to $new_fpath."
            else
                rm -rf $fpath
                echo "Remove $fpath."
            fi
            shopt -u nocasematch
        fi
    done
}

setup_bashrc() {
    bash_path=$HOME/.bash
    if [ -e "$bash_path" -a ! -d "$bash_path" ]; then
        echo "$bash_path exist but is not a folder. Please rename it. Stop."
        exit 1
    fi
    if [ ! -e "$bash_path" ]; then
        git clone https://github.com/yihsiu806/new-bash.git $bash_path
    fi
    for f in $@; do
        fpath=$HOME/.bash/$f
        symlink=$HOME/.$f
        echo "Create symlink $symlink"
        ln -s $fpath $symlink
    done
}

setup_vim() {
    vim_path=$HOME/.vim
    if [ -e "$vim_path" -a ! -d "$vim_path" ]; then
        echo "$vim_path exist but is not a folder. Please rename it. Stop."
        exit 1
    fi
    if [ ! -e "$vim_path" ]; then
        git clone --recursive https://github.com/yihsiu806/vim.git $vim_path
    else
        pushd $vim_path > /dev/null
        git pull
        git rebase
        git submodule update --init --recursive
        popd > /dev/null
    fi

    ln -s $HOME/.vim/vimrc $HOME/.vimrc
}

main
