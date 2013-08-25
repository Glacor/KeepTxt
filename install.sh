#!/bin/bash

# install.sh - KeepTxt install script

# Define default install locations
usrLocal=/usr/local/bin/keeptxt
home=$HOME/keeptxt
conf=$HOME/.keeptxt

echo "Install script for KeepTxt, a command line note taking app"
echo

read -p "What's the name of your notebook [default: KeepTxt]? " namePrompt
if [ "$namePrompt" = '' ]; then
    nbkName="KeepTxt"
else
    nbkName="$namePrompt"
fi

read -p "Install KeepTxt for all users [y/n]? " yorn
if [[ "$yorn" = 'y' || "$yorn" = 'Y' ]]; then
    echo "Installing keeptxt to /usr/local/bin..."
    sudo cp keeptxt.sh $usrLocal
    sudo chown root:root $usrLocal
    sudo chmod 755 $usrLocal
else
    echo "Installing keeptxt to $HOME..."
    cp keeptxt.sh $home
    chmod 700 $home
fi

echo "Installing conf files..."
mkdir $conf
mkdir $conf/.Trash
cp keeptxt.conf $conf/keeptxt.conf
sed -i "s/NBKNAME/$nbkName/" $conf/keeptxt.conf
cp iso8601 $conf/

echo "Creating notebook '$HOME/$nbkName'..."
mkdir "$HOME/$nbkName"

echo
echo "Done."
