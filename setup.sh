#!/bin/bash

DESKTOP=0
VIM=0
ZSH=0
TMUX=0
GOLANG=0

display_usage() {
	echo "This script must be run with root privilege with sudo command."
	echo "Usage: ./setup.sh [args1] [args2] ..."
	echo "Argument can be :"
	echo "	-h : Display usage."
	echo "	-d : Setup Debian desktop."
	echo "	-v : Setup vim."
	echo "	-z : Setup zsh."
	echo "	-t : Setup tmux."
	echo "	-g : Setup golang env."
}

if [[ $# -gt 0 ]] ; then # Check args
	if [[ $# -gt 6 ]] ; then # to much args
		display_usage
		exit 1
	fi
	for i in $* # iterate through the list of args
	do
		if [[ "$i" == "-d" ]] ; then
			DESKTOP=1
		elif [[ "$i" == "-v" ]] ; then
			VIM=1
		elif [[ "$i" == "-z" ]] ; then
			ZSH=1
		elif [[ "$i" == "-t" ]] ; then
			TMUX=1
		elif [[ "$i" == "-g" ]] ; then
			GOLANG=1
		elif [[ "$i" == "-h" ]] ; then
			display_usage
			exit 1
		else
			echo "'$i' is not a valid args."
			display_usage
			exit 1
		fi
	done
fi

# install the required packages 
sudo apt update && sudo apt install -y fonts-powerline vim dconf-cli xsel most zsh bat tmux git curl

if [[ $DESKTOP -eq 1 ]] ; then
	if [[ -z $XDG_CURRENT_DESKTOP ]] || [[ -z $GDMSESSION ]] ; then
		echo "Desktop Environnement and Window Manager are not defined, the installation of Desktop cannot be performed."
		exit 1
	fi
	dconf load /com/gexperts/Terminix/ < conf/desktop/tilix.dconf # load tilix conf
	dconf dump /org/mate/desktop/keybindings/ < conf/desktop/shortcut.dconf # load shortcut 
	sudo update-alternatives --set x-www-browser /usr/bin/firefox-esr # set default browser
	sudo update-alternatives --set editor /usr/bin/vim.basic # set default editor
	sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix # set default terminal emulator
	cp -r config/desktop/autostart/ $HOME/.config/ # set startup program
	echo "[DESKTOP] : OK"
fi


if [[ $VIM -eq 1 ]] ; then
	cp -f config/vimrc /home/$USER/.vimrc
	vim -E -s -u "/home/$USER/.vimrc" +PlugInstall +qa > /dev/null # Install vim plugins and themes
	echo "¨[VIM] : OK"
fi

if [[ $TMUX -eq 1 ]] ; then
	git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
	cp -f config/tmux.conf $USER/.tmux.conf
	/home/$USER/.tmux/plugins/tpm/scripts/install_plugins.sh
	echo "[TMUX] : OK"
fi

if [[ $GOLANG -eq 1 ]] ; then
	mkdir -p $USER/go_projects/{bin,src,pkg}
	wget -c https://golang.org/dl/go1.15.2.linux-amd64.tar.gz 
	tar -C /usr/local -xvzf go1.15.2.linux-amd64.tar.gz
	echo "[GOLANG] : OK"
fi

if [[ $ZSH -eq 1 ]] ; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting 
	cp -f config/zshrc $HOME/.zshrc
	sudo chsh -s $(which zsh) $USER
	echo "[ZSH] : OK"
	echo "Close the session and reopen a new one, to finish the installation."
fi

exit 0
