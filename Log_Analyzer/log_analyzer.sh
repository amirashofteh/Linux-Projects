#!/bin/bash

echo "===================================================="
echo "                    LOG ANALYZER"
echo "===================================================="

echo
echo "Press Enter to continue"
read -r temp

clear

echo "Please enter the log file path:"
read -r logfile

# Check if the file exists and is a regular file
if [ ! -f "$logfile" ]; then
    echo "Error: Log file does not exist."
    exit 1
fi

echo
echo "Log file found!"
echo "Analyzing: $logfile"
echo

# Count different log levels
error_count=$(grep -i "ERROR" "$logfile" | wc -l)
warning_count=$(grep -i "WARNING" "$logfile" | wc -l)
info_count=$(grep -i "INFO" "$logfile" | wc -l)

# Display results
echo "===================================================="
echo "                    LOG RESULTS"
echo "===================================================="

echo "ERROR:   $error_count"
echo "WARNING: $warning_count"
echo "INFO:    $info_count"

echo "===================================================="
echo "Analysis complete."

