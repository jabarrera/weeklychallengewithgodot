#!/bin/sh

############################
###      Packaging       ###
############################

PACKAGING_COMMAND="zip"
PACKAGING_OPTIONS="-j" #quiet and avoid relative path information
BUTLER="butler"
EXPORT_DIR="../.export/html5"
EXPORT_FILE_NAME="weeklygamedevchallenge.zip"


############################
###  Itch.io information ###
############################
ITCHIO_USER_NAME="dibuzapping"
ITCHIO_PROJECT_NAME="weekly-game-dev-challenges-with-godot"
ITCHIO_CHANNEL="HTML5"


## Script

#check zip command
if ! command -v ${PACKAGING_COMMAND} > /dev/null
then
    echo "$PACKAGING_COMMAND not found!"
    exit
fi

#check butler command
if ! command -v ${BUTLER} > /dev/null
then
    echo "Itch.io Butler command not found!"
    exit
fi

if [ ! -d $EXPORT_DIR ]
then
    echo "Export directory '$EXPORT_DIR' not found!"
    exit
fi

echo "Packaging and compressing '$EXPORT_FILE_NAME'..."
set -- $PACKAGING_COMMAND $PACKAGING_OPTIONS $EXPORT_DIR/$EXPORT_FILE_NAME ${EXPORT_DIR}/*
"$@"

if [ ! -f ${EXPORT_DIR}/${EXPORT_FILE_NAME} ]
then
    echo "File '$EXPORT_DIR/$EXPORT_FILE_NAME' not created. Something goes wrong while packaging!"
    exit
fi

echo "Packaging finished!"
echo
echo "Start deploying in itch.io..."
set -- $BUTLER push ${EXPORT_DIR}/${EXPORT_FILE_NAME} $ITCHIO_USER_NAME/$ITCHIO_PROJECT_NAME:$ITCHIO_CHANNEL
"$@"

echo "Deploy process finished."

#Cleaning export directory if everything finished ok
echo
echo "This files are going to be deleted forever: "
set -- ${EXPORT_DIR}/*
echo "$@"
echo
echo "Delete it (y/n)?"
read -r answer

if [ "$answer" = 'y' ]
then
    rm -i "$@"
fi

