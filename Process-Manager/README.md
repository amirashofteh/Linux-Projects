# Disk Usage Analyzer

A Bash script for analyzing Linux disk usage and identifying directories and files that consume the most storage.

This project is part of my **50 Bash Projects** journey, focused on developing practical Linux administration and automation skills.

## Features

* Displays filesystem disk usage
* Analyzes a specified directory
* Identifies the largest directories
* Identifies the largest files
* Sorts storage usage from largest to smallest
* Checks disk usage against a configurable threshold
* Displays warnings when disk usage exceeds the threshold
* Supports human-readable file sizes
* Handles invalid directories
* Uses modular Bash functions

## Requirements

* Linux
* Bash
* Standard Linux utilities:

  * `df`
  * `du`
  * `find`
  * `sort`
  * `head`
  * `awk`
  * `tr`

## Installation

Clone the repository:

```bash
git clone https://github.com/YOUR-USERNAME/BashScripts.git
```

Enter the project directory:

```bash
cd BashScripts/Disk_Usage_Analyzer
```

Make the script executable:

```bash
chmod +x disk_usage_analyzer.sh
```

## Usage

Analyze a specific directory:

```bash
./disk_usage_analyzer.sh /var
```

Analyze the `/home` directory:

```bash
./disk_usage_analyzer.sh /home
```

Analyze the current directory:

```bash
./disk_usage_analyzer.sh
```

## Example Output

```text
========================================
        DISK USAGE ANALYZER
========================================

Analyzing: /var

Filesystem Usage:
----------------------------------------
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        50G   38G   12G  76% /

Disk Usage Status:
----------------------------------------
WARNING: Disk usage is 76%

Largest Directories:
----------------------------------------
2.4G    /var/log
1.8G    /var/lib
850M    /var/cache
320M    /var/tmp

Largest Files:
----------------------------------------
450.20 MB       /var/log/application.log
230.45 MB       /var/log/syslog
120.10 MB       /var/lib/example/data.db

========================================
              SUMMARY
========================================
Directory: /var
Threshold: 75%
Top Items: 10
========================================

Analysis complete.
```

## Configuration

The script contains two configurable variables:

```bash
THRESHOLD=75
TOP_ITEMS=10
```

`THRESHOLD` determines when the script displays a disk usage warning.

`TOP_ITEMS` determines how many of the largest directories and files are displayed.

For example:

```bash
THRESHOLD=80
TOP_ITEMS=20
```

This will warn when disk usage reaches 80% and display the top 20 items.

## How It Works

The script uses several standard Linux utilities.

### `df`

Used to determine filesystem-level disk usage:

```bash
df -h "$DIRECTORY"
```

### `du`

Used to determine directory sizes:

```bash
du -h --max-depth=1 "$DIRECTORY"
```

### `find`

Used to locate files and retrieve their sizes:

```bash
find "$DIRECTORY" -type f -printf '%s %p\n'
```

### `sort`

Used to sort files and directories by size:

```bash
sort -nr
```

### `awk`

Used for processing command output and converting file sizes into human-readable formats.

## Project Structure

```text
Disk_Usage_Analyzer/
├── disk_usage_analyzer.sh
└── README.md
```

## Bash Concepts Practiced

This project practices:

* Bash functions
* Variables
* Command-line arguments
* Default arguments
* Conditional statements
* Exit codes
* Command substitution
* Pipes
* Output redirection
* Text processing
* `df`
* `du`
* `find`
* `sort`
* `head`
* `awk`
* `tr`
* Basic error handling

## Future Improvements

Possible improvements for future versions:

* Add `--threshold` command-line option
* Add `--top` command-line option
* Add command-line argument parsing with `getopts`
* Export reports to CSV
* Generate timestamped reports
* Add logging
* Add interactive directory selection
* Add recursive filesystem analysis
* Add an option to automatically identify directories requiring cleanup

## What I Learned

Through this project I practiced combining multiple Linux commands through pipelines and learned how Bash can be used to automate common system administration tasks.

The main goal was to move beyond basic Bash syntax and start building practical tools that could be useful for Linux system administration and DevOps workflows.

## License

This project is open source and available under the MIT License.
