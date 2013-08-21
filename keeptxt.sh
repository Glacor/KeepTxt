#!/bin/bash

# KeepTxt - A command line note taking app inspired by KeepNote and todo.txt
# by dual

# Define KeepTxt conf directory
keeptxtConf=$HOME/.keeptxt

# Source iso8601 and keeptxt.conf
[ -e $keeptxtConf/iso8601 ] || {
    echo "$HOME/.keeptxt/iso8601 not found... exiting."
    exit 1
}

[ -e $keeptxtConf/keeptxt.conf ] || {
    echo "$HOME/.keeptxt/keeptxt.conf not found... exiting."
    exit 1
}

. $keeptxtConf/iso8601
. $keeptxtConf/keeptxt.conf

# Check that notebook exists
[ -d "$notebook" ] || {
    echo "Default notebook $notebook not found... exiting."
    exit 1
}

# Functions
header()
{
    echo "Starting KeepTxt ( https://github.com/getdual/KeepTxt ) at $isoTime"
    echo
}

attach()
{
    header
    file="$1"
    echo "Available Notes"
    echo "---------------"
    for i in $(ls "$notebook"); do
        echo "$i"
    done
    echo
    read -p "Which note do you want to attach the file to? " note
    [ -d "$notebook/$note" ] || {
        echo "Note '$note' not found... exiting."
        exit 1
    }
    cp -i "$file" "$notebook/$note/"
    echo "Attached $(basename $file) to note '$note'."
    exit 0
}

delete()
{
    header
    note="$1"
    [ -d "$notebook/$note" ] || {
        echo "Note not found... exiting."
        exit 1
    }
    [ -d $keeptxtConf/.Trash ] || {
        echo "Trash directory not found... exiting."
        exit 1
    }
    mv "$notebook/$note" $keeptxtConf/.Trash/
    echo "Deleted note '$note'."
    exit 0
}

empty()
{
    header
    [ -d $keeptxtConf/.Trash ] || {
        echo "Trash directory not found... exiting."
        exit 1
    }
    read -p "Are you sure you want to empty the KeepTxt trash [y/n]? " yorn
    if [[ "$yorn" = 'y' || "$yorn" = 'Y' ]]; then
        rm -rf $keeptxtConf/.Trash/*
        echo "Trash emptied."
        exit 0
    else
        echo "Trash not emptied."
        exit 0
    fi
}

help()
{
cat <<EndHelp
KeepTxt is a command line note taking app inspired by KeepNote and todo.txt.

Usage: keeptxt [NOTE]
       keeptxt [-adehlopsx]

Run keeptxt with a note name and without a switch to create a new, or edit an
existing, note. For example:

  $ keeptxt todo
  $ keeptxt "Army List"

Use the following switches to act upon notes and attachments.

  -a FILE
      Attach a file to a note
  -d NOTE
      Delete a note and its attachments
  -e
      Empty trash of deleted notes
  -h
      This help
  -l
      List notes and attachments
  -o NOTE
      Output a note to the terminal
  -p
      Print all notes (e.g. keeptxt -p | lp to create a hardcopy backup)
  -s
      Save attachment from note to disk
  -x
      Export notebook
EndHelp
}

list()
{
    header
    for i in $(ls "$notebook"); do
        echo "[ $i ]"
        ls "$notebook/$i"
        echo
    done
    echo "Listing complete."
    exit 0
}

output()
{
    header
    note="$1"
    [ -e "$notebook/$note/$note.txt" ] || {
        echo "Note not found... exiting."
        exit 1
    }
    cat "$notebook/$note/$note.txt"
    echo
    echo "Output of note '$note' complete."
    exit 0
}

print()
{
    echo
    echo
    for i in $(ls "$notebook"); do
        echo "[ $i ]"
        if [ -e "$notebook/$i/$i.txt" ]; then
            cat "$notebook/$i/$i.txt"
        else
            echo "Note '$i.txt' not found."
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

save()
{
    header
    echo "Attachments"
    echo "-----------"
    declare -A attachments
    attachCount=1
    for i in $(ls "$notebook"); do
        for j in $(ls --hide="$i.txt" "$notebook/$i"); do
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
    echo "Attachment $chooseAttach saved to $chooseSaveloc."
    exit 0
}

xport()
{
    header
    [ -d "$notebook" ] || {
        echo "Notebook not found... exiting."
        exit 1
    }
    tarball="$nbkName-$shTime.tar.gz"
    cd "$nbkLoc"
    tar czf "$tarball" "$nbkName"
    echo "$nbkName exported to $tarball."
    exit 0
}

newEdit()
{
    header
    newNote="$1"

    # Edit existing note
    if [ -e "$notebook/$newNote/$newNote.txt" ]; then
        nano "$notebook/$newNote/$newNote.txt"
        echo "Edited note '$newNote'."
        exit 0
    fi

    # Create note dir if it doesn't exist
    [ -d "$notebook/$newNote" ] || {
        mkdir "$notebook/$newNote"
    }
    nano "$notebook/$newNote/$newNote.txt"
    echo "Created note '$newNote'."
}

# Help if no args
if [ $# -eq 0 ]; then
    help
    exit 1
fi

while getopts ":a:d:ehlo:psx" opt; do
    case $opt in
        a ) attach "$OPTARG";;
        d ) delete "$OPTARG";;
        e ) empty;;
        h ) help
            exit 0;;
        l ) list;;
        o ) output "$OPTARG";;
        p ) print;;
        s ) save;;
        x ) xport;;
        \? ) echo "Invalid option: -$OPTARG"
            echo
            help
            exit 1;;
        : ) echo "Option -$OPTARG requires an argument."
            echo
            help
            exit 1;;
    esac
done

# Handle single argument for newEdit()
shift $(($OPTIND - 1))
newEdit "$1"
