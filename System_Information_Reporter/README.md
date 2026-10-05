# System Information Menu

A simple Bash script that provides a command-line menu for displaying basic system information.

## Features

The script can display:

* Current username
* Hostname
* Kernel version
* CPU architecture
* System uptime
* Input validation
* Interactive menu
* Exit option

## Requirements

* Linux or Unix-like operating system
* Bash shell

## Usage

Make the script executable:

```bash
chmod +x system_info.sh
```

Run the script:

```bash
./system_info.sh
```

You can also run it directly with Bash:

```bash
bash system_info.sh
```

## Example

```text
==============================
       SYSTEM INFORMATION
==============================
1. Username
2. Hostname
3. Kernel Version
4. CPU Architecture
5. Uptime
6. Exit
==============================

Choose an option: 1

Username: myuser
```

If an invalid option is entered, the script displays an error message and returns to the menu.

## Bash Concepts Used

This project demonstrates several fundamental Bash scripting concepts:

* Functions
* `while` loops
* `case` statements
* User input with `read`
* Command substitution
* `break`
* Input validation
* System commands such as `whoami`, `hostname`, `uname`, and `uptime`

## Commands Used

| Command     | Purpose                                       |
| ----------- | --------------------------------------------- |
| `whoami`    | Displays the current username                 |
| `hostname`  | Displays the system hostname                  |
| `uname -r`  | Displays the kernel version                   |
| `uname -m`  | Displays the CPU architecture                 |
| `uptime -p` | Displays how long the system has been running |

## Project Goal

The goal of this project is to practice Bash functions, loops, conditional logic, user input, and basic Linux system commands while building a simple interactive command-line utility.
