KeepTxt
-------

**Introduction**

KeepTxt is a command line note taking app. KeepTxt allows you to organize and
store your notes, lists, images, and files with the speed and portability of the
command line, all while using the text editor of your choice.

**Installation**

To install KeepTxt:

    wget https://github.com/getdual/KeepTxt/archive/master.zip
    unzip master.zip
    cd KeepTxt-master
    chmod +x install.sh
    ./install.sh

Answer two questions and the installer creates a notebook in your home directory.
You can change the notebook location, default editor, and whether to use secure
empty in ~/.keeptxt/keeptxt.conf. Finally, move the keeptxt executable somewhere
within your path if you don't install it for all users.

**Usage**

KeepTxt runs from the command line and calling it with one argument, a note name,
edits an exisiting note or creates a new note of that name. And KeepTxt supports
tab completion so you don't have to type the whole note name once it exists.

    kt todo
    kt "Army List"

Run kt -h to see the other options.

**Productivity Tips**

Try these aliases for keeptxt in your ~/.bash_aliases file:

    alias kl='kt -l'
    alias kto='kt -o'

Use KeepTxt's print function (-p) to create a hardcopy backup of all of your notes.

    kt -p | lp

If you use cloud storage syncing, like Ubuntu One for example, set your nbkLoc
in keeptxt.conf to the sync directory to have your notes on every device.

    # Define notebook location
    nbkLoc="$HOME/Ubuntu One"    

**License**

KeepTxt is released under the [GPLv3 license](https://github.com/getdual/KeepTxt/blob/master/LICENSE).

Thanks to Gina Trapani for the inspiration of [Todo.txt](http://todotxt.com/).
Please contact [@KeepTxt](https://twitter.com/KeepTxt) with bugs and suggestions.

**- dual**
