#!/bin/bash

# ==========================================================
# Disk Usage Analyzer
# ==========================================================

THRESHOLD=75
TOP_ITEMS=10

# ---------- Colors ----------

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'


# ---------- Functions ----------

show_banner() {
    echo "========================================"
    echo "        DISK USAGE ANALYZER"
    echo "========================================"
    echo
}


show_usage() {
    echo "Usage: $0 [DIRECTORY]"
    echo
    echo "Examples:"
    echo "  $0 /var"
    echo "  $0 /home"
    echo "  $0 ."
    echo
}


check_directory() {

    if [ -z "$1" ]; then
        echo -e "${RED}Error: No directory specified.${NC}"
        echo
        show_usage
        exit 1
    fi

    if [ ! -d "$1" ]; then
        echo -e "${RED}Error: Directory does not exist: $1${NC}"
        exit 1
    fi
}


get_filesystem_usage() {

    echo "Filesystem Usage:"
    echo "----------------------------------------"

    df -h "$1" | awk 'NR==1 || NR==2'

    echo
}


check_disk_threshold() {

    usage=$(df "$1" | awk 'NR==2 {print $5}' | tr -d '%')

    echo "Disk Usage Status:"
    echo "----------------------------------------"

    if [ "$usage" -ge "$THRESHOLD" ]; then
        echo -e "${RED}WARNING: Disk usage is ${usage}%${NC}"
    else
        echo -e "${GREEN}Disk usage is ${usage}% - OK${NC}"
    fi

    echo
}


show_largest_directories() {

    echo "Largest Directories:"
    echo "----------------------------------------"

    du -h --max-depth=1 "$1" 2>/dev/null |
        sort -hr |
        head -n "$TOP_ITEMS"

    echo
}


show_largest_files() {

    echo "Largest Files:"
    echo "----------------------------------------"

    find "$1" -type f -printf '%s %p\n' 2>/dev/null |
        sort -nr |
        head -n "$TOP_ITEMS" |
        awk '{
            size=$1
            $1=""
            sub(/^ /, "", $0)

            if (size >= 1073741824)
                printf "%.2f GB\t%s\n", size/1073741824, $0
            else if (size >= 1048576)
                printf "%.2f MB\t%s\n", size/1048576, $0
            else if (size >= 1024)
                printf "%.2f KB\t%s\n", size/1024, $0
            else
                printf "%d B\t%s\n", size, $0
        }'

    echo
}


show_summary() {

    echo "========================================"
    echo "              SUMMARY"
    echo "========================================"

    echo "Directory: $1"
    echo "Threshold: ${THRESHOLD}%"
    echo "Top Items: $TOP_ITEMS"

    echo "========================================"
    echo
}


# ---------- Main ----------

show_banner

DIRECTORY="${1:-.}"

check_directory "$DIRECTORY"

echo "Analyzing: $DIRECTORY"
echo

get_filesystem_usage "$DIRECTORY"

check_disk_threshold "$DIRECTORY"

show_largest_directories "$DIRECTORY"

show_largest_files "$DIRECTORY"

show_summary "$DIRECTORY"

echo "Analysis complete."
