#!/bin/bash

DESKTOP=0
VIM=0
ZSH=0
TMUX=0
GOLANG=0


# IL faut mieux gerer AFFICHAGE
# Il faut revoir le la fermeture de session zsh 
# 	a voir su - totoro
# 	pourquoi theme tilix pas pris en compte après un redemarrage avec su - totoro	mais apres reset session oui

display_usage() {
	echo -e "Usage: ./setup.sh [args1] [args2] ...\nArgument can be :\n\
	-h : Display usage.\n\
	-d : Setup Debian desktop.\n\
	-v : Setup vim.\n\
	-z : Setup zsh.\n\
	-t : Setup tmux.\n\
	-g : Setup golang env." 
}

if [[ $# -eq 0 ]] ; then # to enough args
	display_usage
	exit 1
elif [[ $# -gt 0 ]] ; then
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
sudo apt-get update > /dev/null && sudo apt-get install -y fonts-powerline fonts-liberation vim dconf-cli xsel most zsh bat tmux git curl tilix > /dev/null 
echo "[PACKAGES]	: OK"

if [[ $DESKTOP -eq 1 ]] ; then
	if [[ -z $XDG_CURRENT_DESKTOP ]] || [[ -z $GDMSESSION ]] ; then
		echo "Desktop Environnement and Window Manager are not defined, the installation of Desktop cannot be performed." 
		exit 1
	fi
	dconf load /com/gexperts/Tilix/ < config/desktop/tilix.dconf > /dev/null # load tilix conf
	dconf load /org/mate/desktop/keybindings/ < config/desktop/shortcut.dconf > /dev/null # load shortcut 
	sudo update-alternatives --set x-www-browser /usr/bin/firefox-esr > /dev/null # set default browser
	sudo update-alternatives --set editor /usr/bin/vim.basic > /dev/null # set default editor
	sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper > /dev/null # set default terminal emulator
	cp -r config/desktop/autostart/ $HOME/.config/ > /dev/null # set startup program
	echo "[DESKTOP] 	: OK"

fi


if [[ $VIM -eq 1 ]] ; then
	cp -f config/vimrc /home/$USER/.vimrc
	vim -E -s -u "/home/$USER/.vimrc" +PlugInstall +qa > /dev/null # Install vim plugins and themes
	echo "[VIM]		: OK"
fi

if [[ $TMUX -eq 1 ]] ; then
	git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm > /dev/null
	cp -f config/tmux.conf $HOME/.tmux.conf
	$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh > /dev/null
	echo "[TMUX]		: OK"
fi

if [[ $GOLANG -eq 1 ]] ; then
	mkdir -p $HOME/go_projects/{bin,src,pkg}
	wget -c https://golang.org/dl/go1.15.2.linux-amd64.tar.gz > /dev/null
	sudo tar -C /usr/local -xvzf go1.15.2.linux-amd64.tar.gz > /dev/null
	echo "[GOLANG]		: OK"
fi

if [[ $ZSH -eq 1 ]] ; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 
	git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions > /dev/null
	git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting > /dev/null
	cp -f config/zshrc $HOME/.zshrc
	sudo chsh -s $(which zsh) $USER
	echo "[ZSH]	: 	OK"
	echo "Close the session and reopen a new one, to finish the installation."
fi

exit 0
