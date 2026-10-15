# Linux User and Group Auditor

A Bash-based Linux security auditing tool that reviews user accounts, login shells, home directories, and privileged group memberships.

## Features

- Lists user accounts and groups.
- Classifies accounts by configurable UID range.
- Detects UID 0 accounts, unusual login shells, and missing home directories.
- Reviews membership in privileged groups.
- Exports audit reports in TXT or CSV format.

## Requirements

- Linux
- Bash
- Standard utilities: `getent`, `awk`, `mkdir`, `dirname`, and `date`

## Usage

```bash
# Show help
./user_group_auditor.sh --help

# List users
./user_group_auditor.sh --users

# List groups
./user_group_auditor.sh --groups

# Run security audit
./user_group_auditor.sh --audit

# Export a CSV report
./user_group_auditor.sh --audit --format csv --output reports/audit.csv
```

## UID Classification

The default regular-user UID range is `1000–59999`. Customize it with `--min-uid` and `--max-uid`.

## Limitations

Audit findings require human review. System configurations vary, and a finding does not automatically indicate a vulnerability. Account data is retrieved through `getent`, which may include accounts provided by configured identity services.

## Version

0.3.0
