#!/bin/bash

rm -f build/donate
mkdir -p build/donate
rsync -a . build/donate --exclude build --exclude .git
cd build/donate

sed -i 's/uappexplorer.bhdouglass/uappexplorer-donate.bhdouglass/g' clickable.json
sed -i 's/uappexplorer.bhdouglass/uappexplorer-donate.bhdouglass/g' manifest.json
sed -i 's/uappexplorer.bhdouglass/uappexplorer-donate.bhdouglass/g' src/Main.qml
mv data/uappexplorer-donate.png data/uappexplorer.png

clickable clean build click-build
