#!/bin/bash

# Run install.sh first or this will fail due to missing dependencies

# network on boot?
read -t 1 -n 1000000 discard      # discard previous input
sudo dhclient enp0s3
echo 'Waiting for internet connection'


# xinitrc
cd
head -n -5 /etc/X11/xinit/xinitrc > ~/.xinitrc
echo 'exec VBoxClient --clipboard -d &' >> ~/.xinitrc
echo 'exec VBoxClient --display -d &' >> ~/.xinitrc
echo 'exec i3 &' >> ~/.xinitrc
echo 'exec nitrogen --restore &' >> ~/.xinitrc
echo 'exec emacs' >> ~/.xinitrc

# emacs config
git clone https://github.com/tsokk/emacs-config.git
echo '(load-file "~/emacs-config/bootstrap.el")' > ~/.emacs
echo '(server-start)' >> ~/.emacs

# xterm setup
echo 'XTerm*background:black' > ~/.Xdefaults
echo 'XTerm*foreground:white' >> ~/.Xdefaults
echo 'UXTerm*background:black' >> ~/.Xdefaults
echo 'UXTerm*foreground:white' >> ~/.Xdefaults

# oh-my-zsh
cd
rm ~/.zshrc -f
echo 'ZSH_THEME="robbyrussell"' > ~/.zshrc
echo 'plugins=(git compleat sudo archlinux emacs autojump common-aliases)/' >> ~/.zshrc

# environment variable
echo 'export EDITOR=emacsclient' >> ~/.zshrc
echo 'export TERMINAL=lxterminal' >> ~/.zshrc

# i3status
if [ ! -d ~/.config ]; then
    mkdir ~/.config
fi
mkdir ~/.config/i3status
cp /etc/i3status.conf ~/.config/i3status/config
sed -i 's/^order += "ipv6"/#order += "ipv6"/' ~/.config/i3status/config
sed -i 's/^order += "run_watch VPN"/#order += "run_watch VPN"/' ~/.config/i3status/config
sed -i 's/^order += "wireless _first_"/#order += "wireless _first_"/' ~/.config/i3status/config
sed -i 's/^order += "battery 0"/#order += "battery 0"/' ~/.config/i3status/config

# git first time setup
git config --global user.name $(whoami)
git config --global user.email $(whoami)@$(hostname)
git config --global code.editor emacsclient
echo '    AddKeysToAgent yes' >> ~/.ssh/config

# if there are ssh key
if [ -d ~/workspace/ssh ]; then
    if [ -d ~/.ssh ]; then
        rm -rf ~/.ssh
    fi
    ln -s ~/workspace/ssh ~/.ssh
fi

# wallpaper setup
cd
mkdir Pictures
cd Pictures
curl -o wallpaper.jpg https://github.com/tsokk/spartan-arch/blob/master/wallpaper.jpg?raw=true
cd ~/.config/
mkdir nitrogen
cd nitrogen
echo '[xin_-1]' > bg-saved.cfg
echo "file=/home/$(whoami)/Pictures/wallpaper.jpg" >> bg-saved.cfg
echo 'mode=0' >> bg-saved.cfg
echo 'bgcolor=#000000' >> bg-saved.cfg

# temporary workaround
cd
curl -o startx.sh https://raw.githubusercontent.com/tsokk/spartan-arch/master/startx.sh
chmod +x startx.sh
echo 'alias startx=~/startx.sh' >> ~/.zshrc

echo 'Done'
~/startx.sh
