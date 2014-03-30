#!/usr/bin/env bash
#===============================================================================
#
#          FILE: install_platform.sh
#
#         USAGE: ./install_platform.sh [api-level]
#                Where api-level is a number between 2 and 19
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

# Where the installed Android SDK is located. It should work on OSX as well a
# Linux.
AND_SDK_DIR=/usr/local/android-sdks

# Where our copy of the SDK is going to sit
MY_SDK_DIR=/tmp/android-sdks

# Eclipse workspace
ECLIPSE_WORKSPACE=$HOME/workspace/
# The user should not have anything to edit beyond this line

# API level. The default level is 8.
API_LEVEL=8

usage() {
    echo "Usage: $0 [api-level]"
    echo "Where the api-level is between 2 and 19."
}

if [[ $1 -gt 19 || $1 -lt 2 ]]; then
    usage
    exit 1
fi

# We can call this script with an argument to get another api level than 8. The
# argument has to be a number from 1 to 19.
if [[ $# -eq 1 ]]; then
    API_LEVEL=$1
fi

# The place where the platform is to be downloaded (perferably in homespace).
MY_API_DIR=$HOME/tmp/android-$API_LEVEL

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

echo mklink "$MY_API_DIR" "$MY_SDK_DIR/platforms"
mklink "$MY_API_DIR" "$MY_SDK_DIR/platforms"

# Edit the eclipse config files
$ECLIPSE_SDK_CONF_FILE=$ECLIPSE_WORKSPACE/.metadata/.plugins/org.eclipse.core.runtime/.settings/com.android.ide.eclipse.adt.prefs
if [[ -d $ECLIPSE_WORKSPACE && -f $ECLIPSE_SDK_CONF_FILE ]]; then
    sed -e\
        "s/com.android.ide.eclipse.adt.sdk=.*/com.android.ide.eclipse.adt.sdk=$MY_SDK_DIR"\
        < $ECLIPSE_SDK_CONF_FILE > $ECLIPSE_SDK_CONF_FILE.2
    mv -f $ECLIPSE_SDK_CONF_FILE.2 $ECLIPSE_SDK_CONF_FILE
else
    echo Eclipse configuration files not found.
    echo "When you start Eclipse, please edit the location of the sdk to:"
    echo "$MY_SDK_DIR."
fi

# Edit $HOME/.android/ddms.cfg
if [[ -d $HOME/.android && -f $HOME/.android/ddms.cfg ]]; then
    sed -e "s:.*lastSdkPath.*:lastSdkPath=$MY_SDK_DIR:" \
        < $HOME/.android/ddms.cfg > $HOME/.android/ddms.cfg.2
    mv -f $HOME/.android/ddms.cfg.2 $HOME/.android/ddms.cfg
else
    echo "Your Android configuration directory can not be found."
fi
