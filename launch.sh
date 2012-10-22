#!/bin/bash

DIR=$(pwd)
cd "$DIR"

if [[ -f "$DIR/version.cfg" ]]; then
    VERSION=$(head -n 1 "$DIR/version.cfg")
else
    VERSION=0
fi

echo ""
echo "=========================================================================="
echo "      MinecraftAKS Updater by Okaria Dragon   http://aureusknights.com"
echo "=========================================================================="
echo ""
echo -n "Locating Java ... "

PLATFORM=$(uname)
JAVA_PATH="java"
JAVA_VER=$($JAVA_PATH -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')

if [[ "$JAVA_VER" == *"command not found"* ]]; then
    echo "Java not found."
else
    JAVA_VER_FULL=$($JAVA_PATH -version 2>&1 | awk -F '"' '/version/ {print $2}')

    if [[ $JAVA_VER -eq 17 ]]; then
        echo "v1.7 found."

        if [[ $PLATFORM -eq "Darwin" ]]; then
            echo "[!!!] WARNING: Java v1.7 on OS X is known to have problems with Minecraft."
            echo -n "Looking for compatible version of Java ... "

            JAVA_PATH="/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home/bin/java"
            if [[ -f "$JAVA_PATH" ]]; then
                JAVA_VER=$($JAVA_PATH -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')
                JAVA_VER_FULL=$($JAVA_PATH -version 2>&1 | awk -F '"' '/version/ {print $2}')
                if [[ $JAVA_VER -eq 16 ]]; then
                    echo "$JAVA_VER_FULL found. Using this version."
                else
                    echo "No known compatible versions of Java could be found. Game may not run properly, or at all."
                fi
            fi
        else
            echo "$JAVA_VER found."
        fi
    else
        echo "$JAVA_VER found."
    fi
fi

echo ""

if [[ -d "$DIR/minecraftdata" ]]; then
    echo -n "Checking for updates ... "
else
    VERSION=0
    echo "Fresh MinecraftAKS installation detected."
fi

curl -s -o "$DIR/update.cfg" --location https://raw.github.com/evansims/MinecraftAKS/master/latest.cfg

if [[ $? -eq 0 ]]; then
    LATEST=$(head -n 1 "$DIR/update.cfg")
    DOWNLOADSIZE=$(head -n 2 "$DIR/update.cfg" | tail -n 1)

    if [[ $LATEST -gt $VERSION ]]; then
        if [[ $VERSION != 0 ]]; then
            echo an update is available.
        fi

        echo "Downloading v$LATEST ($DOWNLOADSIZE) ... "
        curl -s -o "$DIR/changelog.txt" --location https://raw.github.com/evansims/MinecraftAKS/master/changelog.cfg
        curl -s -o "$DIR/minecraft.jar" --location https://raw.github.com/evansims/MinecraftAKS/master/minecraft.jar
        curl -S -o "$DIR/update.tar.gz" --location https://github.com/downloads/evansims/MinecraftAKS/clientdata-v$VERSION.tar.gz

        if [[ $? -eq 0 ]]; then
            echo -n "Extracting files ... "
            tar -zxf "$DIR/update.tar.gz"
            if [[ $? -eq 0 ]]; then
                echo "Done."

                echo -n "Cleaning up ... "
                if [[ -d "$DIR/minecraftdata_old" ]]; then
                    rm -rf "$DIR/minecraftdata_old"
                fi

                if [[ -d "$DIR/minecraftdata" ]]; then
                    mv "$DIR/minecraftdata" "$DIR/minecraftdata_old"
                fi

                mv "$DIR/minecraftdata_update" "$DIR/minecraftdata"

                if [[ -f "$DIR/version.cfg" ]]; then
                    rm "$DIR/version.cfg"
                fi

                rm "$DIR/update.tar.gz"
                mv "$DIR/update.cfg" "$DIR/version.cfg"

                echo "Done."
                echo ""
                echo "Update complete!"
                echo ""
            else
                echo error applying update. Aborting.
            fi
        else
            echo error downloading update. Aborting.
            return
        fi
    else
        echo no update necessary.
    fi
fi

echo Starting MinecraftAKS ...
/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home/bin/java -Xms2048M -Xmx2048M -Duser.home="$(pwd)/minecraftdata" -jar "$(pwd)/minecraft.jar" net.minecraft.LauncherFrame --noupdate
