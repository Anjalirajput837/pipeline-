#!/bin/bash

# Configuration
ZIP_DIR="/home/ubuntu/zip_manager"
LOG_FILE="/home/ubuntu/zip_manager/zip_activity.log"
KEEP_COUNT=5
MAX_LOG_SIZE_BYTES=1024

# Function to manage log file size
manage_log_size() {
    # Check if the log file exists
    if [ -e "$LOG_FILE" ]; then
        # Get the current file size in bytes using 'stat' (GNU/Linux specific) or 'wc -c' (portable)
        # We ll use wc -c' for better portability.
        CURRENT_SIZE=$(wc -c < "$LOG_FILE")

        # Compare the current size with the maximum limit
        if [ "$CURRENT_SIZE" -gt "$MAX_LOG_SIZE_BYTES" ]; then
            # Truncate the file to zero bytes if it exceeds the limit
            # This clears the entire content of the log file
            cat /dev/null > "$LOG_FILE"
            echo "--- $(date '+%Y-%m-%d %H:%M:%S') - Log file size exceeded $MAX_LOG_SIZE_BYTES bytes. File cleared. ---" >> "$LOG_FILE"
        fi
        fi
}

# Create archives directory if it doesn't exist
mkdir -p "$ZIP_DIR"

# Call the function to check and manage the log file size before writing new logs
manage_log_size

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
cd "$ZIP_DIR" || exit

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

# Call the function again at the end of the script to ensure the log size is managed after all operations
manage_log_size

