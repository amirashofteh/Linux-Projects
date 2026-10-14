# Service Status Checker

A Bash utility for checking the status of Linux systemd services. It supports checking multiple services in one execution, reporting service states, returning exit codes, and recording results in a timestamped log file.

## Features

- Check one or multiple systemd services.
- Identify active, inactive, failed, and transitional service states.
- Detect missing service units.
- Return exit codes for automation and monitoring.
- Log service results with timestamps.
- Continue checking other services when a requested service is missing.

## Requirements

- Linux system with systemd
- Bash
- `systemctl`

## Installation

Clone the repository and enter the project directory:

```bash
git clone https://github.com/amirashofteh/Linux-Projects.git
cd Linux-Projects/Service_Status_Checker
chmod +x service_checker.sh
```

## Usage

Check a single service:

```bash
./service_checker.sh ssh
```

Check multiple services:

```bash
./service_checker.sh ssh cron nginx
```

Run without arguments to display usage instructions:

```bash
./service_checker.sh
```

## Service States

| Output | Meaning |
|---|---|
| `[OK]` | Service is active |
| `[WARNING]` | Service is inactive |
| `[CRITICAL]` | Service has failed |
| `[INFO]` | Service is transitioning |
| `[ERROR]` | Service unit was not found |
| `[UNKNOWN]` | State could not be classified |

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | All requested services are active and logging succeeded |
| `1` | At least one service is not active or its state is unknown |
| `2` | Missing arguments, missing service unit, or logging failure |

When multiple problems occur, exit code `2` takes precedence over exit code `1`.

## Logging

Results are appended to:

```text
logs/service_checker.log
```

Example:

```text
2026-10-14 14:00:00 | ssh | active
2026-10-14 14:00:01 | cron | active
```

Each entry contains a timestamp, service name, and reported state.

## Project Structure

```text
Service_Status_Checker/
├── service_checker.sh
├── README.md
└── logs/
    └── service_checker.log
```

## Future Improvements

- Optional command-line arguments for custom log paths.
- Summary of active and non-active services.
- Log rotation.
- Optional JSON output for integration with monitoring tools.

## Learning Objectives

This project demonstrates Bash scripting, command-line argument handling, functions, loops, conditional logic, `systemctl` integration, exit codes, and file logging.

## License

MIT License — add a `LICENSE` file if you choose to distribute the project under this license.
