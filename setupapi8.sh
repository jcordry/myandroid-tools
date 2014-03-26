#!/usr/bin/env bash
# Author: Julien Cordry
# Date: 25 03 2014
# The aim of this script is to create a SDK directory for Android that
# includes api level 8. It should work in the Linux labs. The created
# directory is thereafter usable from Eclipse. Just indicate the location of the
# directory from windows>preferences. This could be adapted to support any
# other kind of api or library support for Android. If you plan on using it as
# such or modified in your project, make sure to include it as part of the
# submission.
# See:
# http://dl-ssl.google.com/android/repository/repository-8.xml
# for more on what can be added. E.g.:
# wget http://dl-ssl.google.com/android/repository/19_r03.zip
# Note that it does not copy anything. It creates directories and makes links to
# existing directories, but nothing is hard copied.

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
    ./getplatform 8
    # scp -r apple33.scm.tees.ac.uk:$AND_SDK_DIR/platforms/android-8 $MY_API8_DIR
fi

# Creates a directory if it does not exist already and gets into it.
mkdir_cd() {
    DIR="$1"
    if [[ ! -d "$DIR" ]]; then
        mkdir "$DIR"
    fi
    cd "$DIR"
}

# Creates a symbolic link to the target in the current folder if it does not
# exist already.
mklink() {
    TARGET="$1"
    BASE=`basename "$TARGET"`
    if [[ ! -h "$BASE" ]]; then
        ln -s "$TARGET" "$BASE"
    fi
}

mkdir_cd "$MY_SDK_DIR"

# Link everything but platforms from the SDK installation directory.
for file in $AND_SDK_DIR/*; do
    BASE=`basename "$file"`
    if [[ "$BASE" != platforms ]]; then
        mklink "$file"
    fi
done

mkdir_cd platforms

# Link everything from the platforms directory.
for folder in $AND_SDK_DIR/platforms/*; do
    mklink "$folder"
done

mklink "$MY_API8_DIR"

cd "$CUR_DIR"
