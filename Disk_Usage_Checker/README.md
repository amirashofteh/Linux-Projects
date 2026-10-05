# Disk Usage Checker

A simple Bash script that checks the disk usage of a specified directory and warns the user when disk usage reaches or exceeds 80%.

## Features

* Accepts a directory path from the user
* Checks whether the directory exists
* Retrieves disk usage using `df`
* Extracts the disk usage percentage using `awk`
* Removes the `%` symbol using `tr`
* Warns the user when disk usage is 80% or higher
* Uses a clean exit status when an invalid directory is provided

## Requirements

* Linux or Unix-like operating system
* Bash
* Standard Linux utilities:

  * `df`
  * `awk`
  * `tr`

## Usage

Make the script executable:

```bash
chmod +x disk_usage_checker.sh
```

Run the script:

```bash
./disk_usage_checker.sh
```

Enter the directory you want to check:

```text
Enter your directory to check:
/home
```

Example output:

```text
Directory: /home
Disk Usage: 67%
===============================================
Disk usage is normal.
```

If disk usage is 80% or higher:

```text
Directory: /home
Disk Usage: 85%
===============================================
WARNING: Disk usage is high!
```

## Concepts Practiced

This project was created to practice:

* Bash scripting
* Variables
* User input with `read`
* Command substitution
* Conditional statements
* Directory validation
* Exit status
* `df`
* `awk`
* `tr`
* Numeric comparison

## Project Structure

```text
disk_usage_checker/
├── disk_usage_checker.sh
└── README.md
```

## Future Improvements

Possible improvements for future versions:

* Allow the warning threshold to be configured by the user
* Check multiple directories
* Add colored terminal output
* Display available and used disk space
* Add logging
* Run automatically with cron
* Send an alert when disk usage becomes critical

## Author

Created as part of a personal Bash scripting practice and DevOps learning project.
