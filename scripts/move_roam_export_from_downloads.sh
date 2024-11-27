#!/bin/bash

# Set the directory paths
DOWNLOAD_DIR="/home/saurabh/Downloads"
DESTINATION_DIR="/home/saurabh/code/roam-viewer-js/src/assets"

# Check for dry run mode
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "Running in dry run mode. No files will be modified."
fi

# Function to execute or simulate a command
execute_command() {
  if $DRY_RUN; then
    echo "[DRY RUN] Would execute: $@"
  else
    "$@"
  fi
}

# Find the most recent saurabhs-*.json file
LATEST_JSON=$(find "$DOWNLOAD_DIR" -maxdepth 1 -name "saurabhs-*.json" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")

if [ -z "$LATEST_JSON" ]; then
  echo "No saurabhs-*.json file found in $DOWNLOAD_DIR"
  exit 1
fi

echo "Found latest JSON file: $LATEST_JSON"

# Extract the date from the filename
DATE_FROM_FILENAME=$(basename "$LATEST_JSON" | grep -oP '\d{4}-\d{2}-\d{2}')

if [ -z "$DATE_FROM_FILENAME" ]; then
  echo "Couldn't extract date from filename"
  exit 1
fi

DAY_BEFORE=$(date -d "$DATE_FROM_FILENAME - 1 day" +%Y-%m-%d)

# Define the new filenames
NEW_FILENAME="saurabhs.json"
DATED_FILENAME="${DAY_BEFORE}-saurabhs.json"

# Copy the file to the destination directory
execute_command cp "$LATEST_JSON" "$DESTINATION_DIR/$NEW_FILENAME"

echo "Copied $LATEST_JSON to $DESTINATION_DIR/$NEW_FILENAME"

# Rename the file with just the date
execute_command mv "$LATEST_JSON" "$DOWNLOAD_DIR/$DATED_FILENAME"

echo "Renamed $LATEST_JSON to $DOWNLOAD_DIR/$DATED_FILENAME"
