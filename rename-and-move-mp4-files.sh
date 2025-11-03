#!/bin/bash

rootFolderPath="$1"

echo "Starting renaming script..."

if [ -z "$rootFolderPath" ]; then
    echo "You must provide the root folder path as the first argument for this script!"
    exit 1
fi

echo "Renaming MP4s included in ${rootFolderPath}..."

# Find all .MP4 files recursively
find "$rootFolderPath" -type f -iname "*.mp4" | while read -r selectedFilePath; do
    # Extract "Media created" date using exiftool
    mediaCreatedString=$(exiftool -MediaCreateDate "$selectedFilePath" | awk -F': ' '{print $2}' | sed 's/\//-/g')

    if [ -n "$mediaCreatedString" ]; then
        echo "${selectedFilePath} media created string is ${mediaCreatedString}"

        dateString=$(echo "$mediaCreatedString" | sed 's/:/-/') # replace 1st occurrence of colon with hyphen
        dateString=$(echo "$dateString" | sed 's/:/-/') # replace 2nd occurrence of colon with hyphen
        echo "Formatting ${dateString} into date..."
        formattedDateString=$(date --date "$dateString" +"%Y-%m-%d_%I%M_%p") # create correctly formatted date
        
        directoryName=$(dirname "$selectedFilePath")
        newFileName="${formattedDateString}.MP4"
        newFilePath="${directoryName}/${newFileName}"

        echo "Renaming ${selectedFilePath} to ${newFileName}..."
        mv "$selectedFilePath" "$newFilePath"

        echo "Moving ${newFilePath} to ${rootFolderPath}..."
        mv "$newFilePath" "$rootFolderPath"
    fi
done

echo "Finished renaming script!"
