#!/usr/bin/env bash
# Author: Julien Cordry
# Date: 25 03 2014
# The aim of this script is to download a version of the Android platform for a
# given version from the Google website. This can be used in case eclipse does
# not allow you to do it, say if the folder where the Android sdk is installed
# does not allow us to write.

usage() {
    echo "Usage: $0 <api-level> <dest-folder>"
    echo "Where the api-level is between 1 and 19."
}

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

if [[ $1 -gt 19 || $1 -lt 1 ]]; then
    usage
    exit 1
fi

LEVEL=$1
DEST_FOLDER=$2

ROOTURL=http://dl-ssl.google.com/android/repository
REPXML=repository-8.xml

case $1 in
    2) LEVEL=-1.1
        ;;
    3) LEVEL=-1.5
        ;;
    4) LEVEL=-1.6
        ;;
    5) LEVEL=-2.0
        ;;
    6) LEVEL=-2.0.1
        ;;
    7) LEVEL=-2.1
        ;;
    8) LEVEL=-2.2
        ;;
    9) LEVEL=-2.3.1
        ;;
    10) LEVEL=-2.3.3
        ;;
    11) LEVEL=-3.0
        ;;
    12) LEVEL=-3.1
        ;;
    13) LEVEL=-3.2
        ;;
    *) LEVEL=-$LEVEL
esac

if [[ ! -f "$DEST_FOLDER/$REPXML" ]]; then
    wget -nv "$ROOTURL/$REPXML" -P "$DEST_FOLDER"
fi

if [[ $1 -le 6 ]]; then
    FILE=`grep 'sdk:url>android' "$DEST_FOLDER/$REPXML" | sed -e 's/\(.*\)\(and\)/\2/' -e\
        's/<.*//' | grep -e "$LEVEL" | grep linux`
    SHA=`grep -B 1 -e "android$LEVEL" "$DEST_FOLDER/$REPXML" | grep -B 1 linux | grep sha1 | sed -e 's/.*sha1">//' -e 's/<.*//'`
else
    FILE=`grep 'sdk:url>android' "$DEST_FOLDER/$REPXML" | sed -e 's/\(.*\)\(and\)/\2/' -e\
        's/<.*//' | grep -e "$LEVEL"`
    SHA=`grep -B 1 -e "android$LEVEL" "$DEST_FOLDER/$REPXML" | grep sha1 | sed -e 's/.*sha1">//' -e 's/<.*//'`
fi

if [[ ! -f $FILE ]]; then
    wget -nv "$ROOTURL/$FILE" -P "$DEST_FOLDER"
    echo "$SHA  $DEST_FOLDER/$FILE" | sha1sum -c > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Checksum failed! Aborting..."
        exit 1
    fi
fi

if [[ $1 -le 13 ]]; then
    FOLDER=${FILE%.zip}
else
    case $1 in
        14)
            VERSION=4.0;;
        15)
            VERSION=4.0.3;;
        16)
            VERSION=4.1.2;;
        17)
            VERSION=4.2.2;;
        18)
            VERSION=4.3;;
        19)
            VERSION=4.4;;
    esac
    FOLDER=android-$VERSION
fi

if [[ ! -d $DEST_FOLDER/$FOLDER ]]; then
    echo "unzipping the file"
    echo unzip -q "$DEST_FOLDER/$FILE" -d "$DEST_FOLDER"
    echo unzip -q "$DEST_FOLDER/$FILE" -d "$DEST_FOLDER/$FOLDER"
    unzip -q "$DEST_FOLDER/$FILE" -d "$DEST_FOLDER"
fi

if [[ ! -h "$DEST_FOLDER/android-$1" ]]; then
    ln -s "$DEST_FOLDER/$FOLDER" "$DEST_FOLDER/android-$1"
fi
