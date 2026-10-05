# Log Analyzer

A simple Bash script that analyzes a log file and counts different types of log messages.

## Description

The Log Analyzer accepts a log file path from the user and analyzes its contents.

It counts the number of lines containing:

- ERROR
- WARNING
- INFO

The script also performs basic file validation before analyzing the log.

## Features

- Accepts a log file path from the user
- Checks whether the specified file exists
- Verifies that the path is a regular file
- Counts ERROR messages
- Counts WARNING messages
- Counts INFO messages
- Case-insensitive log analysis
- Displays a simple summary of the results

## Requirements

- Linux or another Unix-like operating system
- Bash
- `grep`
- `wc`

## Usage

Make the script executable:

```bash
chmod +x log_analyzer.sh
