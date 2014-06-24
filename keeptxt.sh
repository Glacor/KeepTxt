#!/bin/bash

# KeepTxt - A command line note taking app
# by dual (whenry)

# Handle empty notebook gracefully
shopt -s nullglob

Version='0.91'

# Define KeepTxt conf directory
keeptxtConf=$HOME/.keeptxt

# Source iso8601 and keeptxt.conf
[ -e $keeptxtConf/iso8601 ] || {
    echo "$keeptxtConf/iso8601 not found... exiting"
    exit 1
}

[ -e $keeptxtConf/keeptxt.conf ] || {
    echo "$keeptxtConf/keeptxt.conf not found... exiting"
    exit 1
}

. $keeptxtConf/iso8601
. $keeptxtConf/keeptxt.conf

# Check that notebook exists
[ -d "$notebook" ] || {
    echo "Default notebook $notebook not found... exiting"
    exit 1
}

# Functions
header() {
    echo
    echo "Starting KeepTxt ( http://keeptxt.com ) at $isoTime"
    echo
}

options() {
cat <<EndOpts
  -a FILE
      Attach a file to a note
  -d NOTE
      Delete a note and its attachments
  -e
      Empty trash of deleted notes
  -g STRING
      Grep (search) for string in notes
  -h
      Help message
  -l
      List notes and attachments
  -o NOTE
      Output a note to the terminal
  -p
      Print all notes
  -r NOTE
      Rename a note
  -s
      Save an attachment from note to disk
  -v
      Display KeepTxt version
  -x
      Export notebook

EndOpts
}

longHelp() {
cat <<EndHelp

KeepTxt is a command line note taking app.

Usage: kt [NOTE]
       kt [-adeghloprsvx]

Run kt with no options and a note name to create a new, or edit the existing,
note. For example:

  kt todo
  kt "Army List"

KeepTxt supports tab completion so you don't have to type the entire note name.
Use the following options to act upon notes and attachments.

EndHelp

options
}

shortHelp() {
    echo
    echo "Usage: kt [NOTE]"
    echo "       kt [-adeghloprsvx]"
    echo
    options
}

attach() {
    header
    local file="$1"
    currentDir=$(pwd)
    echo "Available Notes"
    echo "---------------"
    cd "$notebook"
    for i in *; do
        echo "$i"
    done
    cd $currentDir
    echo
    read -p "Which note do you want to attach the file to? " noteWquotes
    note=$(echo "$noteWquotes" | sed 's/"//g')
    [ -d "$notebook/$note" ] || {
        echo "Note '$note' not found... exiting"
        exit 1
    }
    cp -i "$file" "$notebook/$note/"
    echo "Attached $(basename $file) to note '$note'"
    echo
    exit 0
}

delete() {
    header
    local note="$1"
    [ -d "$notebook/$note" ] || {
        echo "Note not found... exiting"
        echo
        exit 1
    }
    [ -d $keeptxtConf/.Trash ] || {
        echo "Trash directory not found... exiting"
        echo
        exit 1
    }
    if [ -d "$keeptxtConf/.Trash/$note" ]; then
        mv "$notebook/$note" "$keeptxtConf/.Trash/$note-1"
    else
        mv "$notebook/$note" $keeptxtConf/.Trash/
    fi
    echo "Deleted note '$note'"
    echo
    exit 0
}

empty() {
    header
    [ -d $keeptxtConf/.Trash ] || {
        echo "Trash directory not found... exiting"
        echo
        exit 1
    }
    read -p "Are you sure you want to empty the KeepTxt trash [y/n]? " yorn
    if [[ "$yorn" = 'y' || "$yorn" = 'Y' ]]; then
        if [ $secureEmpty = '1' ]; then
            if [[ $(which srm) =~ 'srm' ]]; then
                srm -rl $keeptxtConf/.Trash/*
                echo "Trash securely emptied."
                echo
                exit 0
            else
                echo "Secure empty set but srm not found... exiting"
                echo
                exit 1
            fi
        else
            rm -rf $keeptxtConf/.Trash/*
            echo "Trash emptied"
            echo
            exit 0
        fi
    else
        echo "Trash not emptied"
        echo
        exit 0
    fi
}

grepNote() {
    header
    local string="$1"
    cd "$notebook"
    for i in *; do
        grep "$string" "$i/$i.txt"
    done
    echo
    echo "Search for '$string' complete"
    echo
    exit 0
}

list() {
    header
    cd "$notebook"
    echo "Notes"
    echo "-----"
    for i in *; do
        echo "$i"
    done
    echo
    echo
    echo "Attachments"
    echo "-----------"
    for i in *; do
        cd "$notebook/$i"
        for j in *; do
            if [ "$j" != "$i.txt" ]; then
                echo "$i/$j"
            fi
        done
    done
    echo
    echo "Listing complete"
    echo
    exit 0
}

output() {
    header
    local note="$1"
    [ -e "$notebook/$note/$note.txt" ] || {
        echo "Note not found... exiting"
        echo
        exit 1
    }
    cat "$notebook/$note/$note.txt"
    echo
    echo "Output of note '$note' complete"
    echo
    exit 0
}

print() {
    echo
    echo
    cd "$notebook"
    for i in *; do
        echo "[ $i ]"
        if [ -e "$notebook/$i/$i.txt" ]; then
            cat "$notebook/$i/$i.txt"
        else
            echo "Note '$i.txt' not found"
        fi
        echo
        echo "Attachments"
        echo "-----------"
        ls --hide="$i.txt" "$notebook/$i"
        echo
        echo
    done
    exit 0
}

rename() {
    header
    local note="$1"
    cd "$notebook"
    [ -d "$note" ] || {
        echo "Note '$note' does not exist... exiting"
        echo
        exit 1
    }
    read -p "What is the note's new name? " newName
    if [ -e "$note/$note.txt" ]; then
        mv -i "$note/$note.txt" "$note/$newName.txt"
    fi
    mv "$note" "$newName"
    echo "Note '$note' renamed to '$newName'"
    echo
    exit 0
}

save() {
    header
    echo "Attachments"
    echo "-----------"
    declare -A attachments
    attachCount=1
    cd "$notebook"
    for i in *; do
        for j in $(ls --hide="$i.txt" "$i"); do
            k="$i/$j"
            attachments[$attachCount]="$k"
            echo "$attachCount: $k"
            attachCount=$((attachCount+=1))
        done
    done
    echo
    read -p "Please choose an attachment number: " chooseAttach
    attachLoc="$notebook/${attachments[$chooseAttach]}"
    read -p "Where would you like to save the attachment? " chooseSaveloc
    cp -i "$attachLoc" "$chooseSaveloc"
    echo
    echo "Attachment $chooseAttach saved to $chooseSaveloc"
    echo
    exit 0
}

version() {
    echo
    echo "KeepTxt version $Version ( http://keeptxt.com )"
    echo
    exit 0
}

xport() {
    header
    [ -d "$nbkLoc" ] || {
        echo "Notebook directory '$nbkLoc' not found... exiting"
        echo
        exit 1
    }
    tarball="$nbkName-$shTime.tar.gz"
    cd "$nbkLoc"
    tar czf "$tarball" "$nbkName"
    echo "$nbkName exported to $tarball"
    echo
    exit 0
}

newEdit() {
    header
    local note="$1"

    # Edit existing note
    if [ -e "$notebook/$note/$note.txt" ]; then
        $EDITOR "$notebook/$note/$note.txt"
        echo "Edited note '$note'"
        echo
        exit 0
    fi

    # Create note dir if it doesn't exist
    [ -d "$notebook/$note" ] || {
        mkdir "$notebook/$note"
    }
    $EDITOR "$notebook/$note/$note.txt"
    echo "Created note '$note'."
    echo
}

# Short help if no args
if [ $# -eq 0 ]; then
    shortHelp
    exit 1
fi

while getopts ":a:d:eg:hlo:pr:svx" opt; do
    case $opt in
        a ) attach "$OPTARG";;
        d ) delete "$OPTARG";;
        e ) empty;;
        g ) grepNote "$OPTARG";;
        h ) longHelp
            exit 0;;
        l ) list;;
        o ) output "$OPTARG";;
        p ) print;;
        r ) rename "$OPTARG";;
        s ) save;;
        v ) version;;
        x ) xport;;
        \? ) echo
            echo "Invalid option: -$OPTARG"
            shortHelp
            exit 1;;
        : ) echo
            echo "Option -$OPTARG requires an argument"
            shortHelp
            exit 1;;
    esac
done

# Handle single argument for newEdit()
shift $(($OPTIND - 1))
newEdit "$1"
