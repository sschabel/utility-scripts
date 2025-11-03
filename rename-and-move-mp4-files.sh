#!/bin/bash

rootFolderPath="$1"
destFolderPath="$2"

if [ "$rootFolderPath" = "help" ]; then
    echo "You must provide the root folder path as the 1st argument for this script."
    echo "The 2nd argument is optional, but is the location where you want the renamed MP4 files to be placed."
    echo "By default, the renamed files will be placed at the path specified in the 1st argument if you do not"
    echo "supply the 2nd argument."
    exit 1
fi

if [ -z "$rootFolderPath" ]; then
    echo "You must provide the root folder path as the first argument for this script!"
    echo "Use 'help' as an argument for more details on what this script requires."
    exit 1
fi

echo "Renaming MP4s included in ${rootFolderPath}..."

# Find all .MP4 files recursively
find "$rootFolderPath" -type f -iname "*.mp4" | while read -r selectedFilePath; do
    # Extract "Media created" date using exiftool
    mediaCreatedString=$(exiftool -MediaCreateDate "$selectedFilePath" | awk -F': ' '{print $2}' | sed 's/\//-/g')

    if [ -n "$mediaCreatedString" ]; then
        dateString=$(echo "$mediaCreatedString" | sed 's/:/-/') # replace 1st occurrence of colon with hyphen
        dateString=$(echo "$dateString" | sed 's/:/-/') # replace 2nd occurrence of colon with hyphen
        formattedDateString=$(date --date "$dateString" +"%Y-%m-%d_%I%M_%p") # create correctly formatted date
        
        directoryName=$(dirname "$selectedFilePath")
        newFileName="${formattedDateString}.MP4"
        newFilePath="${directoryName}/${newFileName}"

        echo "Renaming ${selectedFilePath} to ${newFileName}..."
        mv "$selectedFilePath" "$newFilePath"

        if [ -z "$destFolderPath" ]; then
            echo "Moving ${newFilePath} to ${rootFolderPath}..."
            mv "$newFilePath" "$rootFolderPath"
        else
            echo "Moving ${newFilePath} to ${destFolderPath}..."
            mv "$newFilePath" "$destFolderPath"
        fi
    fi
done

echo "Finished renaming script!"
