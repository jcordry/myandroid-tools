#!/usr/bin/env bash

defaultavd=22
if [[ $# -eq 1 ]]; then
    echo $1
    avd=$1
else
    echo "usage: $0 [22|41]"
    echo The version of Android is by default set to $defaultavd
    avd=$defaultavd
    exit 1
fi

system=`uname`
localdir=/Volumes/DATA/scratch/$USER/
avddir=avd-$system$avd
toolpath=/usr/local/android-sdks/tools

createdir() {
    if [[ ! -d $1 ]]; then
        mkdir $1
    fi
}

createdir $localdir
chmod 700 $localdir
createdir $localdir/$avddir
# might not be necessary
createdir $localdir/workspace

case $avd in
    22) id=1;;
41) id=2;; # no ABI!
esac

if [[ ! -f $localdir/$avddir/config.ini ]]
then
    echo no | $toolpath/android create avd -p $localdir/$avddir -f -n $system$avd -t $id -a
fi

screen $toolpath/emulator-arm -avd $system$avd

