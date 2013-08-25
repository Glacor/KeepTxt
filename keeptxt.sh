#!/bin/bash

# KeepTxt - A command line note taking app
# by dual

# Define KeepTxt conf directory
keeptxtConf=$HOME/.keeptxt

# Source iso8601 and keeptxt.conf
[ -e $keeptxtConf/iso8601 ] || {
    echo "$keeptxtConf/iso8601 not found... exiting."
    exit 1
}

[ -e $keeptxtConf/keeptxt.conf ] || {
    echo "$keeptxtConf/keeptxt.conf not found... exiting."
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

options()
{
cat <<EndOpts
  -a FILE
      Attach a file to a note
  -d NOTE
      Delete a note and its attachments
  -e
      Empty trash of deleted notes
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
  -x
      Export notebook
EndOpts
}

longHelp()
{
cat <<EndHelp
KeepTxt is a command line note taking app for systems with GNU Bash.

Usage: keeptxt [NOTE]
       keeptxt [-adehlopsx]

Run keeptxt with no options and a note name to create a new, or edit the
existing, note. For example:

  $ keeptxt todo
  $ keeptxt "Army List"

Use the following options to act upon notes and attachments.

EndHelp

options
}

shortHelp()
{
    echo "Usage: keeptxt [NOTE]"
    echo "       keeptxt [-adehlopsx]"
    echo
    options
}

attach()
{
    header
    file="$1"
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

list()
{
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
    cd "$notebook"
    for i in *; do
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

rename()
{
    header
    note="$1"
    cd "$notebook"
    [ -d "$note" ] || {
        echo "Note '$note' does not exist... exiting."
        exit 1
    }
    read -p "What is the note's new name? " newName
    if [ -e "$note/$note.txt" ]; then
        mv -i "$note/$note.txt" "$note/$newName.txt"
    fi
    mv "$note" "$newName"
    echo "Note '$note' renamed to '$newName'."
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
    note="$1"

    # Edit existing note
    if [ -e "$notebook/$note/$note.txt" ]; then
        nano "$notebook/$note/$note.txt"
        echo "Edited note '$note'."
        exit 0
    fi

    # Create note dir if it doesn't exist
    [ -d "$notebook/$note" ] || {
        mkdir "$notebook/$note"
    }
    nano "$notebook/$note/$note.txt"
    echo "Created note '$note'."
}

# Short help if no args
if [ $# -eq 0 ]; then
    shortHelp
    exit 1
fi

while getopts ":a:d:ehlo:pr:sx" opt; do
    case $opt in
        a ) attach "$OPTARG";;
        d ) delete "$OPTARG";;
        e ) empty;;
        h ) longHelp
            exit 0;;
        l ) list;;
        o ) output "$OPTARG";;
        p ) print;;
        r ) rename "$OPTARG";;
        s ) save;;
        x ) xport;;
        \? ) echo "Invalid option: -$OPTARG"
            echo
            shortHelp
            exit 1;;
        : ) echo "Option -$OPTARG requires an argument."
            echo
            shortHelp
            exit 1;;
    esac
done

# Handle single argument for newEdit()
shift $(($OPTIND - 1))
newEdit "$1"
