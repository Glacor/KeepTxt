#!/bin/bash

# install.sh - KeepTxt install script

# Define default install locations
home="$HOME/kt"
conf="$HOME/.keeptxt"
rcfile="$rcfile"

echo "Installing KeepTxt, a command line note taking app"
echo

read -p "What's the name of your notebook [default: KeepTxt]? " namePrompt
if [ "$namePrompt" = '' ]; then
    nbkName="KeepTxt"
else
    nbkName="$namePrompt"
fi

echo "Installing kt to $HOME..."
cp keeptxt.sh $home
chmod 700 $home

echo "Installing conf files..."
mkdir $conf
mkdir $conf/.Trash
cp keeptxt.conf $conf/keeptxt.conf
sed -i "s/NBKNAME/$nbkName/" $conf/keeptxt.conf
cp iso8601 $conf/

read -p "Enable secure empty of KeepTxt trash [y/n]? " ynEmpty
if [[ "$ynEmpty" = 'y' || "$ynEmpty" = 'Y' ]]; then
    echo "Enabling secure empty..."
    echo "  Make sure the srm command is installed."
    sed -i "s/secureEmpty=0/secureEmpty=1/" $conf/keeptxt.conf
fi

echo "Installing tab completion..."
echo >> $rcfile
echo '#############################' >> $rcfile
echo '# Added by KeepTxt install.sh' >> $rcfile
echo >> $rcfile
echo '# Source keeptxt.conf' >> $rcfile
echo '. $HOME/.keeptxt/keeptxt.conf' >> $rcfile
echo >> $rcfile
echo '# Create tab completion for kt' >> $rcfile
echo '_kt()' >> $rcfile
echo '{' >> $rcfile
echo '    local cur=${COMP_WORDS[COMP_CWORD]}' >> $rcfile
echo '    COMPREPLY=( $(compgen -W "$(cd "$notebook"; ls)" -- $cur) )' >> $rcfile
echo '}' >> $rcfile
echo 'complete -F _kt kt' >> $rcfile
echo >> $rcfile
echo '# Added by KeepTxt install.sh' >> $rcfile
echo '#############################' >> $rcfile
echo "  Open a new shell or '. .bashrc' to enable tab completion."

echo "Creating notebook '$HOME/$nbkName'..."
mkdir "$HOME/$nbkName"

echo
echo "Complete"
