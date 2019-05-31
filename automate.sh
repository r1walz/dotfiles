#!/bin/sh

# Run the script in /home/username/opt

# [1] First get touchpad gestures working
sudo pacman -S xf86-input-synaptics
sudo mv touchpad/70-synaptics.conf /etc/X11/xorg.conf.d/
# The above should make all gestures work
echo "Touchpad Gestures should work now!!"


# [2] Make brightness key bindings work. This is added coz xbacklit doesn't work sometimes out of the box
git clone https://github.com/haikarainen/light.git
cd light/
./autogen.sh
./configure
make
sudo make install
cd ..
# This will add light package for controlling the brightness
echo "Light package added, key bindings should work now"
# The above step is necessary coz it's used in i3-config for brightness controls

# [3] Install yay as AUR helper
git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si
cd ..
echo "yay added as AUR helper"
# The above step is needed to install AUR packages through terminal

# [4] Install necessary packages wrt sound
sudo pacman -S alsa-utils alsa-firmware pulseaudio pavucontrol
# Start pulseaudio
pulseaudio --start
# Enable pulseaudio in usermode
systemctl --user enable pulseaudio.service
systemctl --user start pulseaudio.service
# This will most likely not work and will require a reboot to work correctly. Reboot later when everything is done
echo "Pulseaudio is all setup"

# [5] Install a bunch of usefull packages
sudo pacman -S arandr lxappearance unzip ranger thunar ttf-dejavu noto-fonts-cjk noto-fonts-emoji noto-fonts xdotool
# Install some AUR packages
yay -S google-chrome ttf-font-awesome ttf-freefont ttf-ms-fonts ttf-linux-libertine ttf-dejavu ttf-inconsolata ttf-ubuntu-font-family apulse
echo "Bunch of useful packages installed"


# Everything is set up now. Add the config files now
mv i3-config ~/.config/i3/config
mv xresources ~/.Xresources

# Installing bash-it
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh
echo "Bash it installed. Copying bashrc now..."
mv bashrc ~/.bashrc