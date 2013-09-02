#!/bin/bash

# install.sh - KeepTxt install script

# Define default install locations
usrLocal=/usr/local/bin/kt
home=$HOME/kt
conf=$HOME/.keeptxt

echo "Install script for KeepTxt, a command line note taking app"
echo

read -p "What's the name of your notebook [default: KeepTxt]? " namePrompt
if [ "$namePrompt" = '' ]; then
    nbkName="KeepTxt"
else
    nbkName="$namePrompt"
fi

read -p "Install KeepTxt for all users [y/n]? " ynInstall
if [[ "$ynInstall" = 'y' || "$ynInstall" = 'Y' ]]; then
    echo "Installing keeptxt to /usr/local/bin..."
    sudo cp keeptxt.sh $usrLocal
    sudo chown root:root $usrLocal
    sudo chmod 755 $usrLocal
else
    echo "Installing keeptxt to $HOME..."
    echo "  Place the keeptxt executable somewhere in your \$PATH."
    cp keeptxt.sh $home
    chmod 700 $home
fi

echo "Installing conf files..."
mkdir $conf
mkdir $conf/.Trash
cp keeptxt.conf $conf/keeptxt.conf
sed -i "s/NBKNAME/$nbkName/" $conf/keeptxt.conf
cp iso8601 $conf/

read -p "Enable secure empty of KeepTxt trash [y/n]? " ynEmpty
if [[ "$ynEmpty" = 'y' || "$yorn" = 'Y' ]]; then
    echo "Enabling secure empty..."
    echo "  Make sure the srm command is installed."
    sed -i "s/secureEmpty=0/secureEmpty=1/" $conf/keeptxt.conf
fi

echo "Installing tab completion..."
echo >> $HOME/.bashrc
echo '#############################' >> $HOME/.bashrc
echo '# Added by KeepTxt install.sh' >> $HOME/.bashrc
echo >> $HOME/.bashrc
echo '# Source keeptxt.conf' >> $HOME/.bashrc
echo '. $HOME/.keeptxt/keeptxt.conf' >> $HOME/.bashrc
echo >> $HOME/.bashrc
echo '# Create tab completion for kt' >> $HOME/.bashrc
echo '_kt()' >> $HOME/.bashrc
echo '{' >> $HOME/.bashrc
echo '    local cur=${COMP_WORDS[COMP_CWORD]}' >> $HOME/.bashrc
echo '    COMPREPLY=( $(compgen -W "$(cd "$notebook"; ls)" -- $cur) )' >> $HOME/.bashrc
echo '}' >> $HOME/.bashrc
echo 'complete -F _kt kt' >> $HOME/.bashrc
echo >> $HOME/.bashrc
echo '# Added by KeepTxt install.sh' >> $HOME/.bashrc
echo '#############################' >> $HOME/.bashrc
echo "  Open a new shell or '. .bashrc' to enable tab completion."

echo "Creating notebook '$HOME/$nbkName'..."
mkdir "$HOME/$nbkName"

echo
echo "Done."
