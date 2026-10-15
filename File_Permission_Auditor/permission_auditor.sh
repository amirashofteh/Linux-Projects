#!/usr/bin/env bash
# File Permission Auditor
# Read-only Linux filesystem permission scanner

set -uo pipefail
export LC_ALL=C

readonly VERSION="1.0.0"

usage() {
    cat <<'EOF'
File Permission Auditor

Usage:
  ./permission_auditor.sh <path> [--report <file>]

Options:
  -h, --help       Show this help message
  -v, --version    Show version information
  --report <file>  Save findings to a report file

Exit codes:
  0  Audit completed without findings
  1  Audit completed with findings
  2  Invalid arguments
  3  Operational error
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 3
}

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            printf 'File Permission Auditor v%s\n' "$VERSION"
            exit 0
            ;;
    esac
done

if [[ $# -lt 1 ]]; then
    usage >&2
    exit 2
fi

AUDIT_PATH=""
REPORT_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --report)
            if [[ $# -lt 2 || -z "$2" || "$2" == -* ]]; then
                printf 'ERROR: --report requires a filename\n' >&2
                exit 2
            fi
            REPORT_FILE=$2
            shift 2
            ;;
        -*)
            printf 'ERROR: Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
        *)
            if [[ -n "$AUDIT_PATH" ]]; then
                printf 'ERROR: Only one audit path is allowed\n' >&2
                exit 2
            fi
            AUDIT_PATH=$1
            shift
            ;;
    esac
done

if [[ -z "$AUDIT_PATH" ]]; then
    printf 'ERROR: An audit path is required\n' >&2
    exit 2
fi

if [[ ! -e "$AUDIT_PATH" && ! -L "$AUDIT_PATH" ]]; then
    die "Path does not exist: $AUDIT_PATH"
fi

if [[ -L "$AUDIT_PATH" ]]; then
    die "The audit path itself is a symbolic link; audit its target explicitly"
fi

if [[ ! -r "$AUDIT_PATH" ]]; then
    die "Path is not readable: $AUDIT_PATH"
fi

if [[ -d "$AUDIT_PATH" && ! -x "$AUDIT_PATH" ]]; then
    die "Directory cannot be traversed: $AUDIT_PATH"
fi

if [[ -n "$REPORT_FILE" && -e "$REPORT_FILE" && "$REPORT_FILE" -ef "$AUDIT_PATH" ]]; then
    die "Report file must not overwrite the audit target"
fi

if [[ -n "$REPORT_FILE" && -d "$REPORT_FILE" ]]; then
    die "Report destination is a directory"
fi

if [[ -n "$REPORT_FILE" && "$REPORT_FILE" == "$AUDIT_PATH/"* ]]; then
    printf 'ERROR: Choose a report destination outside the audited path\n' >&2
    exit 2
fi

tmp_report=$(mktemp) || die "Cannot create temporary report"
trap 'rm -f -- "$tmp_report"' EXIT

find_errors=0
findings=0
scanned=0

{
    printf '%s\n' "File Permission Auditor v$VERSION"
    printf 'Audit path: %s\n' "$AUDIT_PATH"
    printf 'Started: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
    printf '%s\n\n' '----------------------------------------'

    while IFS= read -r -d '' entry; do
        ((scanned += 1))

        # Inspect the object itself; do not follow symbolic links.
        if ! metadata=$(stat -c '%A|%a|%U|%G|%F' -- "$entry" 2>/dev/null); then
            printf 'ERROR: Cannot inspect: %s\n' "$entry" >&2
            find_errors=1
            continue
        fi

        IFS='|' read -r perms mode owner group type <<< "$metadata"

        reasons=()

        # Last three octal digits: world permissions.
        world=$((8#${mode: -1}))

        if (( world & 2 )); then
            reasons+=("WORLD-WRITABLE")
        fi

        # Special permission bits: SUID=4, SGID=2.
        mode_value=$((8#$mode))

        if (( mode_value & 04000 )); then
            reasons+=("SUID")
        fi

        if (( mode_value & 02000 )); then
            reasons+=("SGID")
        fi

        # Other-readable files may expose data more broadly than intended.
        if [[ ! -d "$entry" ]] && (( world & 4 )); then
            reasons+=("WORLD-READABLE")
        fi

        if (( ${#reasons[@]} > 0 )); then
            ((findings += 1))
            printf '[FINDING] %s\n' "$entry"
            printf '  Type: %s\n' "$type"
            printf '  Mode: %s (%s)\n' "$perms" "$mode"
            printf '  Owner: %s | Group: %s\n' "$owner" "$group"
            printf '  Flags: %s\n\n' "${reasons[*]}"
        fi
    done < <(
        find -P "$AUDIT_PATH" -print0 2>/dev/null
    )

    printf '%s\n' '----------------------------------------'
    printf 'Objects inspected: %d\n' "$scanned"
    printf 'Objects with findings: %d\n' "$findings"
    printf 'Traversal errors: %d\n' "$find_errors"
} > "$tmp_report"

# Check for traversal failures separately.
if ! find -P "$AUDIT_PATH" -print0 >/dev/null 2>&1; then
    find_errors=1
fi

if (( find_errors )); then
    printf 'WARNING: Some filesystem objects may not have been inspected.\n' >&2
fi

if [[ -n "$REPORT_FILE" ]]; then
    if ! cp -- "$tmp_report" "$REPORT_FILE"; then
        die "Cannot write report: $REPORT_FILE"
    fi
    printf 'Report saved to: %s\n' "$REPORT_FILE"
fi

cat -- "$tmp_report"

if (( find_errors )); then
    exit 3
elif (( findings > 0 )); then
    exit 1
else
    exit 0
fi
