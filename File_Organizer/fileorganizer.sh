#!/bin/bash

echo "===================================================="
echo "              WELCOME TO FILE ORGANIZER"
echo "===================================================="

echo "Please enter your directory:"
read -r enter

# Check if directory exists
if [ ! -d "$enter" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

# Move into the selected directory
cd "$enter" || exit 1

echo
echo "Organizing files..."
echo

for file in *
do
    # Only process regular files
    if [ -f "$file" ]; then

        case "$file" in

            # Images
            *.jpg|*.jpeg|*.png|*.gif)
                mkdir -p images
                mv -- "$file" images/
                echo "Moved $file -> images/"
                ;;

            # Documents
            *.pdf|*.doc|*.docx|*.txt)
                mkdir -p documents
                mv -- "$file" documents/
                echo "Moved $file -> documents/"
                ;;

            # Music
            *.mp3|*.wav|*.flac)
                mkdir -p music
                mv -- "$file" music/
                echo "Moved $file -> music/"
                ;;

            # Videos
            *.mp4|*.mkv|*.avi)
                mkdir -p videos
                mv -- "$file" videos/
                echo "Moved $file -> videos/"
                ;;

            # Everything else
            *)
                mkdir -p others
                mv -- "$file" others/
                echo "Moved $file -> others/"
                ;;

        esac
    fi
done

echo
echo "===================================================="
echo "           FILE ORGANIZATION COMPLETED"
echo "===================================================="
