#!/bin/bash

echo -n "Building latest.tar.gz ... "

mv minecraftdata minecraftdata_update

rm "./minecraftdata_update/Library/Application Support/minecraft/lastlogin" &> /dev/null
rm -rf "./minecraftdata_update/Library/Application Support/minecraft/stats/*" &> /dev/null
find "./minecraftdata_update/" -name \.DS_Store -exec rm -v {} \; &> /dev/null
find "./minecraftdata_update/" -name \*.log -exec rm -v {} \; &> /dev/null

tar -czf latest.tar.gz minecraftdata_update/
mv minecraftdata_update minecraftdata

echo "Done."

echo "Remember to update latest.cfg so users can download it!"
return

ORIGINAL=$1
TARGET=$2

if [[ "$ORIGINAL" ]]; then
    if [[ "$TARGET" ]]; then
        if [[ -d "$ORIGINAL" ]]; then
            if [[ -d "$TARGET" ]]; then
                FILENAME="$ORIGINAL-$TARGET.patch"
                diff -rupN "$ORIGINAL/" "$TARGET/" > "$FILENAME"
                return
            fi
        fi
    fi
fi

echo You must provide an original and target directory name.

#rm Library/Application\ Support/minecraft/stats/*
