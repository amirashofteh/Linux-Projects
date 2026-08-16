# Linux Server Health Monitor

A Bash-based Linux system monitoring tool that collects system, resource, process, service, network, and basic security information and evaluates the overall health of the machine.

This is **Project 01** of my `LinuxProjects` repository.

## Overview

The Linux Server Health Monitor is designed to provide a quick health check of a Linux system from the command line.

Instead of manually checking multiple Linux utilities, the script gathers important information and presents it in a single structured report.

The project focuses on practical Linux administration concepts such as system information, resource monitoring, process management, `systemd`, networking, SSH, firewalls, and listening ports.

## Features

### System Information

* Hostname
* Operating system
* Kernel version
* CPU architecture
* System uptime

### Resource Monitoring

* CPU usage
* Memory usage
* Root filesystem disk usage
* 1-minute load average

### Process Monitoring

* Number of running processes
* Process consuming the most CPU
* Process consuming the most memory

### Service Monitoring

* Number of failed `systemd` services
* SSH service status
* Docker service status
* Nginx service status

The script also handles services that are not installed.

### Network Monitoring

* Primary IP address
* Default gateway
* Internet connectivity
* DNS resolution

### Security Checks

* SSH status
* Firewall status
* Number of listening TCP ports

The script attempts to detect common Linux firewall implementations such as UFW and nftables.

### Health Evaluation

The collected information is evaluated against predefined thresholds.

Example:

```text
CPU Usage
< 70%       → OK
70–89%      → WARNING
≥ 90%       → CRITICAL
```

Similar thresholds are used for memory and disk usage.

The script then generates an overall status:

```text
HEALTHY
WARNING
CRITICAL
```

## Project Structure

```text
project-01-server-health-monitor/
│
├── README.md
└── server_health_monitor.sh
```

## Technologies and Tools

* Bash
* Linux
* systemd
* `systemctl`
* `ps`
* `top`
* `free`
* `df`
* `ip`
* `ss`
* `ping`
* `getent`
* `awk`
* `grep`
* `cut`

## Requirements

A Linux environment with:

* Bash
* Core Linux utilities
* `systemd` for service checks
* `iproute2` for networking commands
* `procps` for process/resource utilities

The script is designed to work on common Linux distributions, although the availability of individual services and firewall tools may vary between distributions.

## Installation

Clone the repository:

```bash
git clone <repository-url>
```

Navigate to the project:

```bash
cd LinuxProjects/project-01-server-health-monitor
```

Make the script executable:

```bash
chmod +x server_health_monitor.sh
```

## Usage

Run the health monitor:

```bash
./server_health_monitor.sh
```

The script will collect information about the current Linux system and display the results in the terminal.

## Example Output

```text
==========================================================
             LINUX SERVER HEALTH MONITOR
==========================================================

SYSTEM
----------------------------------------------------------
Hostname             : linux-server
Operating System     : Ubuntu 24.04 LTS
Kernel               : 6.x
Architecture         : x86_64
Uptime               : up 2 days, 4 hours

RESOURCES
----------------------------------------------------------
CPU Usage            : 23% [OK]
Memory Usage         : 47% [OK]
Disk Usage           : 82% [WARNING]
Load Average         : 0.42

PROCESSES
----------------------------------------------------------
Running Processes    : 184
Top CPU Process      : firefox (32.5%)
Top Memory Process   : firefox (18.2%)

SERVICES
----------------------------------------------------------
Failed Services      : 0
SSH                  : RUNNING
Docker               : RUNNING
Nginx                : NOT INSTALLED

NETWORK
----------------------------------------------------------
IP Address            : 192.168.1.20
Default Gateway       : 192.168.1.1
Internet              : ONLINE
DNS Resolution        : OK

SECURITY
----------------------------------------------------------
SSH                  : RUNNING
Firewall             : ACTIVE
Listening TCP Ports  : 4

==========================================================
OVERALL STATUS: WARNING
==========================================================
```

The exact output will depend on the Linux system where the script is executed.

## How It Works

The script is divided into several logical components.

### 1. Information Collection

Linux commands and system interfaces are used to collect information about the machine.

Examples include:

```bash
hostname
uname
free
df
ps
ip
ss
```

System information is also obtained from Linux interfaces such as:

```text
/etc/os-release
/proc/loadavg
```

### 2. Service Monitoring

`systemctl` is used to inspect `systemd` services and identify failed services.

The script also checks whether services such as SSH, Docker, and Nginx are installed before attempting to determine their status.

### 3. Network Monitoring

The script checks:

```text
IP address
Default gateway
Internet connectivity
DNS resolution
```

This provides a basic network health check without requiring external monitoring software.

### 4. Security Checks

The script checks the SSH service, firewall state, and currently listening TCP ports.

### 5. Health Evaluation

Collected metrics are compared against predefined thresholds.

For example:

```text
CPU ≥ 90% → CRITICAL
CPU ≥ 70% → WARNING
CPU < 70% → OK
```

The individual results are then combined to determine the overall system health.

## Linux Concepts Practiced

This project was designed to strengthen practical Linux administration skills.

Topics covered include:

* Linux system information
* `/etc` configuration files
* `/proc` filesystem
* Processes
* CPU and memory monitoring
* Disk/filesystem monitoring
* `systemd`
* Service management
* Network interfaces
* Routing
* DNS
* TCP listening sockets
* SSH
* Firewalls
* Exit codes
* Bash functions
* Command substitution
* Pipes
* Text processing with `awk` and `grep`
* Conditional logic
* Error handling

## Bash Concepts Practiced

The project also reinforces:

* Variables
* Functions
* Function arguments
* `if / elif / else`
* Command substitution
* Pipes
* Output redirection
* Exit codes
* Numeric comparisons
* `printf`
* Local variables
* Command detection with `command -v`

## Future Improvements

Possible improvements for future versions include:

* Add command-line arguments
* Add configurable health thresholds
* Add logging
* Generate HTML reports
* Add colored terminal output
* Add historical health data
* Add automatic alerts
* Run automatically using cron or a `systemd` timer
* Add more security checks
* Add support for additional Linux distributions
* Add automated tests

## Learning Objective

The primary objective of this project was not simply to write a Bash script.

The goal was to use Linux-native tools and interfaces to understand how a Linux system exposes information about its:

```text
System
Resources
Processes
Services
Network
Security
```

and then automate the collection and interpretation of that information.

## Project Status

**Completed — Version 1.0**

This project is part of my ongoing Linux and DevOps learning portfolio.
