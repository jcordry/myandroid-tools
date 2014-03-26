#!/usr/bin/env bash
# Author: Julien Cordry
# Date: 25 03 2014
# The aim of this script is to download a version of the Android platform for a
# given version from the Google website. This can be used in case eclipse does
# not allow you to do it, say if the folder where the Android sdk is installed
# does not allow us to write.

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <api-level>"
    echo "Where the api-level is between 1 and 19."
    exit 1
fi

VERSION=$1

ROOTURL=http://dl-ssl.google.com/android/repository
REPXML=repository-8.xml

case $1 in
    2) VERSION=-1.1
        ;;
    3) VERSION=-1.5
        ;;
    4) VERSION=-1.6
        ;;
    5) VERSION=-2.0
        ;;
    6) VERSION=-2.0.1
        ;;
    7) VERSION=-2.1
        ;;
    8) VERSION=-2.2
        ;;
    9) VERSION=-2.3.1
        ;;
    10) VERSION=-2.3.3
        ;;
    11) VERSION=-3.0
        ;;
    12) VERSION=-3.1
        ;;
    13) VERSION=-3.2
        ;;
esac

if [[ ! -f $REPXML ]]; then
    wget $ROOTURL/$REPXML
fi

if [[ $1 -le 6 ]]; then
    FILE=`grep 'sdk:url>android' $REPXML | sed -e 's/\(.*\)\(and\)/\2/' -e\
        's/<.*//' | grep -e $VERSION | grep linux`
    SHA=`grep -B 1 -e android$VERSION $REPXML | grep -B 1 linux | grep sha1 | sed -e 's/.*sha1">//' -e 's/<.*//'`
    echo "$SHA  $FILE"
else
    FILE=`grep 'sdk:url>android' $REPXML | sed -e 's/\(.*\)\(and\)/\2/' -e\
        's/<.*//' | grep -e $VERSION`
    SHA=`grep -B 1 -e android$VERSION $REPXML | grep sha1 | sed -e 's/.*sha1">//' -e 's/<.*//'`
    echo "$SHA  $FILE"
fi

if [[ ! -f $FILE ]]; then
    wget $ROOTURL/$FILE
    echo "$SHA  $FILE" | sha1sum -c > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Checksum failed! Aborting..."
        exit 1
    fi
fi


FOLDER=${FILE%.zip}

if [[ ! -d $FOLDER ]]; then
    unzip -q $FILE
fi

if [[ ! -h android-$1 ]]; then
    ln -s $FOLDER android-$1
fi
