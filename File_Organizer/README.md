📂 File Organizer

A simple Bash script that automatically organizes files in a selected directory into categorized folders based on their file extensions.

This project is designed as a beginner-friendly Bash scripting exercise covering directory validation, loops, conditional statements, pattern matching, file operations, and error handling.

🚀 Features
Accepts a directory path from the user.
Checks whether the specified directory exists.
Safely moves into the selected directory.
Automatically detects regular files.
Organizes files into categories:
🖼️ Images
📄 Documents
🎵 Music
🎬 Videos
📦 Others
Automatically creates category directories when needed.
Displays every file movement in the terminal.
Handles files with spaces in their names.
Leaves existing directories untouched.
📁 File Categories
Category	File Extensions
images/	.jpg, .jpeg, .png, .gif
documents/	.pdf, .doc, .docx, .txt
music/	.mp3, .wav, .flac
videos/	.mp4, .mkv, .avi
others/	Any other file type
🛠️ Requirements
Linux, macOS, or WSL
Bash

Check your Bash version with:

bash --version
📥 Installation

Clone the repository:

git clone https://github.com/amirashofteh/BashScripts.git

Move into the project directory:

cd BashScripts

Navigate to the File Organizer project:

cd file_organizer

Make the script executable:

chmod +x file_organizer.sh
▶️ Usage

Run the script:

./file_organizer.sh

The script will ask you to enter the directory you want to organize:

====================================================
              WELCOME TO FILE ORGANIZER
====================================================
Please enter your directory:
/home/user/Downloads

The script then processes the files and moves them into their appropriate directories.

Example output:

Organizing files...

Moved photo.jpg -> images/
Moved report.pdf -> documents/
Moved song.mp3 -> music/
Moved movie.mp4 -> videos/
Moved archive.zip -> others/

====================================================
           FILE ORGANIZATION COMPLETED
====================================================
📂 Example

Before running the script:

Downloads/
├── photo.jpg
├── vacation.png
├── report.pdf
├── notes.txt
├── song.mp3
├── movie.mp4
├── archive.zip
└── existing_folder/

After running the script:

Downloads/
├── images/
│   ├── photo.jpg
│   └── vacation.png
│
├── documents/
│   ├── report.pdf
│   └── notes.txt
│
├── music/
│   └── song.mp3
│
├── videos/
│   └── movie.mp4
│
├── others/
│   └── archive.zip
│
└── existing_folder/

Existing directories are not moved because the script only processes regular files.

🧠 Bash Concepts Practiced

This project demonstrates several important Bash scripting concepts:

User Input
read -r enter

Reads the directory path entered by the user.

Directory Validation
if [ ! -d "$enter" ]; then

Checks whether the provided path is an existing directory.

Changing Directories
cd "$enter" || exit 1

Moves into the selected directory and exits if the operation fails.

For Loop
for file in *
do
    ...
done

Loops through the contents of the directory.

File Test
if [ -f "$file" ]; then

Ensures that only regular files are processed.

Case Statement
case "$file" in

Matches filenames against different extension patterns.

Directory Creation
mkdir -p images

Creates the destination directory if it does not already exist.

Moving Files
mv -- "$file" images/

Moves the selected file into its corresponding category.

Quoting Variables
"$file"

Quoting paths helps the script correctly handle filenames containing spaces or special characters.

⚠️ Notes

The script currently organizes only files located directly inside the selected directory. It does not recursively organize files inside subdirectories.

File extensions are also matched exactly as written. For example:

photo.jpg

will be categorized as an image, while:

photo.JPG

will currently be placed in others/.

🔮 Possible Improvements

Future versions could include:

Case-insensitive extension matching.
Recursive directory organization.
Support for more file extensions.
A dry-run mode.
Confirmation before moving files.
Duplicate filename handling.
Logging operations to a file.
Command-line arguments instead of interactive input.
Colored terminal output.
An undo feature.
Configuration file for custom categories.
🎯 Learning Objective

The goal of this project is to practice fundamental Bash scripting concepts while building a practical Linux automation tool.

It is part of my Bash scripting practice and focuses on developing skills that are useful for Linux administration, system automation, and DevOps.

👨‍💻 Author

Amir Hossein Ashofteh

GitHub: amirashofteh

⭐ If you find this project useful, feel free to explore the other Bash scripting projects in this repository.
