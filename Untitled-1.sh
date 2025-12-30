#!/bin/bash

# Configuration
ZIP_DIR="/home/ubuntu/zip_manager"
LOG_FILE="/home/ubuntu/zip_manager/zip_activity.log"
KEEP_COUNT=5
#MAX_LOG_SIZE_BYTES=1048576 # 1 MB

# Create archives directory if it doesn't exist
mkdir -p "$ZIP_DIR"

# Log start time
echo "--- $(date '+%Y-%m-%d %H:%M:%S') - Script started ---" >> "$LOG_FILE"

# 1. Generate a new zip file with a timestamp in its name
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
ZIP_FILE="archive_$TIMESTAMP.zip"

# Example: Zipping some dummy content (replace with your actual zipping command)
# For demonstration, we create a dummy file first
echo "Dummy content for $ZIP_FILE" > "$ZIP_DIR/dummy_file.txt"
zip -j "$ZIP_DIR/$ZIP_FILE" "$ZIP_DIR/dummy_file.txt" >> "$LOG_FILE" 2>&1
rm "$ZIP_DIR/dummy_file.txt" # Remove the dummy source file
echo "Generated new zip file: $ZIP_FILE" >> "$LOG_FILE"
# 2. Keep only the latest 5 zip files and remove older ones
cd "$ZIP_DIR" || exit

# List files by modification time (newest first), skip the first $KEEP_COUNT files, and delete the rest
FILES_TO_DELETE=$(ls -Art *.zip | head -n -"$KEEP_COUNT")

if [ -n "$FILES_TO_DELETE" ]; then
    echo "Deleting old zip files:" >> "$LOG_FILE"
    echo "$FILES_TO_DELETE" >> "$LOG_FILE"
    # Use xargs with -0 for safety if filenames contain spaces (though our timestamp naming is safe)
    ls -Art *.zip | head -n -"$KEEP_COUNT" | xargs rm --
    echo "Deletion complete." >> "$LOG_FILE"
else
    echo "Fewer than $KEEP_COUNT files found. No files deleted." >> "$LOG_FILE"
fi
