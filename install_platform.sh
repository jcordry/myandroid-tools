#!/usr/bin/env bash
#===============================================================================
#
#          FILE: install_platform.sh
#
#         USAGE: ./install_platform.sh <api-level>
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

# In case we can't do pushd/popd, we could mark the current dir to get back to
# it later.
CUR_DIR=$PWD

# Where the Android SDK is located. It should work on OSX as well a Linux.
AND_SDK_DIR=/usr/local/android-sdks

# Where our copy of the SDK is going to sit
MY_SDK_DIR=/tmp/android-sdks

# To be configured to the place where you downloaded the SDK
MY_API8_DIR=$HOME/tmp/android-8

# You will have to use your password
if [[ ! -d "$MY_API8_DIR" ]]; then
    cd `dirname $MY_API8_DIR`
    $CUR_DIR/getplatform.sh 8
    cd $CUR_DIR
fi

# Creates a directory if it does not exist already and gets into it.
mymkdir() {
    DIR="$1"
    if [[ ! -d "$DIR" ]]; then
        mkdir -p "$DIR"
    fi
}

# Creates a symbolic link to the target if it does not exist already.
mklink() {
    SRC="$1"
    DEST="$2"
    BASE=`basename "$SRC"`
    if [[ ! -h "$DEST/$BASE" ]]; then
        ln -s "$SRC" "$DEST/$BASE"
    fi
}

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

mklink "$MY_API8_DIR" "$MY_SDK_DIR/platforms"

