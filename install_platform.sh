#!/usr/bin/env bash
#===============================================================================
#
#          FILE: install_platform.sh
#
#         USAGE: ./install_platform.sh [api-level]
#                Where api-level is a number between 1 and 19
#
#   DESCRIPTION: This script sets up a new working directory for the
#   Android/Eclipse plugin in the Linux labs
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Julien Cordry
#  ORGANIZATION:
#       CREATED: 26/03/2014 08:17
#      REVISION:  ---
#===============================================================================

# Where the Android SDK is located. It should work on OSX as well a Linux.
AND_SDK_DIR=/usr/local/android-sdks

# Where our copy of the SDK is going to sit
MY_SDK_DIR=/tmp/android-sdks

# API level. The default level is 8.
API_LEVEL=8

# The place where the platform is to be downloaded (perferably in homespace).
MY_API_DIR=$HOME/tmp/android-$API_LEVEL

# We can call this script with an argument to get another api level than 8. The
# argument has to be a number from 1 to 19.
if [[ $# -eq 1 ]]; then
    API_LEVEL=$1
fi

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mymkdir
#   DESCRIPTION:  Recursively creates a directory if it does not exist already.
#    PARAMETERS:  The directory to be created.
#       RETURNS:  
#-------------------------------------------------------------------------------
mymkdir() {
    DIR="$1"
    if [[ ! -d "$DIR" ]]; then
        mkdir -p "$DIR"
    fi
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mklink
#   DESCRIPTION:  Creates a symbolic link to the target if it does not exist
#   already.
#    PARAMETERS:  The source of the copy and the destination folder.
#       RETURNS:  
#-------------------------------------------------------------------------------
mklink() {
    SRC="$1"
    DEST="$2"
    BASE=`basename "$SRC"`
    if [[ ! -h "$DEST/$BASE" ]]; then
        ln -s "$SRC" "$DEST/$BASE"
    else 
        DIFF=`diff "$DEST/$BASE" "$SRC" > /dev/null 2>&1`
        if [[ $DIFF -ne 0 ]]; then
            rm -f "$DEST/$BASE"
            ln -s "$SRC" "$DEST/$BASE"
        fi
    fi
}

if [[ ! -d "$MY_API_DIR" ]]; then
    DIRNAME=`dirname $MY_API_DIR`
    mymkdir $DIRNAME
    ./getplatform.sh $API_LEVEL $DIRNAME
fi

mymkdir "$MY_SDK_DIR"

# Link everything but platforms from the SDK installation directory.
for file in $AND_SDK_DIR/*; do
    BASE=`basename "$file"`
    if [[ "$BASE" != platforms ]]; then
        mklink "$file" "$MY_SDK_DIR"
    fi
done

mymkdir "$MY_SDK_DIR/platforms"

# Link everything from the platforms directory.
for file in "$AND_SDK_DIR"/platforms/*; do
    mklink "$file" "$MY_SDK_DIR/platforms"
done

mklink "$MY_API_DIR" "$MY_SDK_DIR/platforms"

# Edit ~/.android/ddms.cfg
if [[ -d ~/.android && -f ~/.android/ddms.cfg ]]; then
    sed -e "s:.*lastSdkPath.*:lastSdkPath=/tmp/android-sdks/:" \
        < ~/.android/ddms.cfg > ~/.android/ddms.cfg.2
    mv -f ~/.android/ddms.cfg.2 ~/.android/ddms.cfg
fi
