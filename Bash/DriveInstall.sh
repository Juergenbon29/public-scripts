#!/bin/bash

if [ -e /Applications/Google\ Drive.app ]
then
    exit
else
    cd ~/Downloads || exit 1
    curl -LO https://dl.google.com/drive-file-stream/GoogleDrive.dmg
    hdiutil mount GoogleDrive.dmg
    installer -pkg /Volumes/Install\ Google\ Drive/GoogleDrive.pkg -target /
    hdiutil unmount /Volumes/Install\ Google\ Drive/
fi