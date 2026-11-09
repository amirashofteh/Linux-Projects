# 🔐 File Permission Auditor

A Bash-based Linux security auditing tool that scans files and directories for potentially risky permissions, identifies special permission bits, and generates readable audit reports.

Built on Kali Linux as **Project #09** in my 50-project Linux administration and cybersecurity roadmap.

## 📌 Overview

Linux file permissions control who can read, write, and execute files, as well as who can access directories. Incorrectly configured permissions can expose sensitive information or allow unauthorized modifications.

The File Permission Auditor automates basic permission checks by inspecting filesystem objects and identifying configurations that may require security review.

The script is designed to be **read-only**: it reports potential issues without intentionally modifying file permissions or ownership.

## ✨ Features

- **Filesystem inspection:** Scan a user-specified file or directory.
- **Permission analysis:** Display symbolic and octal permission modes.
- **Ownership information:** Report file owners and groups.
- **World-writable detection:** Identify objects that allow write access to other users.
- **World-readable detection:** Flag non-directory objects readable by other users.
- **SUID detection:** Identify objects with the Set User ID permission bit.
- **SGID detection:** Identify objects with the Set Group ID permission bit.
- **Report generation:** Display results in the terminal and optionally save them to a file.
- **Command-line options:** Support help and version information.
- **Error handling:** Validate arguments and report common path and operational errors.
- **Symbolic-link precautions:** Avoid following symbolic links during traversal and reject a symbolic link as the initial audit path.

## 🛠️ Technologies

- Bash
- Linux filesystem permissions
- `find`
- `stat`
- `mktemp`
- `chmod`
- `coreutils`
- Kali Linux

## 📂 Project Structure

```text
File_Permission_Auditor/
├── permission_auditor.sh
├── README.md
├── reports/
└── tests/
    └── lab/
```

- `permission_auditor.sh` — Main auditing script.
- `reports/` — Directory for saved audit reports.
- `tests/` — Directory for controlled permission-testing scenarios.
- `README.md` — Project documentation.

## ⚙️ Installation

Clone the repository:

```bash
git clone <YOUR_REPOSITORY_URL>
cd File_Permission_Auditor
```

Make the script executable:

```bash
chmod +x permission_auditor.sh
```

No additional software packages are required on a typical Kali Linux installation with Bash and GNU command-line utilities available.

## 🚀 Usage

### Display help

```bash
./permission_auditor.sh --help
```

### Display version

```bash
./permission_auditor.sh --version
```

### Audit a directory

```bash
./permission_auditor.sh tests/lab
```

### Audit a specific file

```bash
./permission_auditor.sh tests/lab/public.txt
```

### Save an audit report

```bash
./permission_auditor.sh tests/lab --report reports/audit.txt
```

The script displays the audit results in the terminal. When `--report` is specified, it also attempts to save the report to the requested destination.

## 🔍 Detection Rules

### 1. World-writable permissions

Files or directories with the world-write bit set are flagged because other local users may be able to modify them, subject to filesystem permissions and other system controls.

Example:

```bash
chmod 666 public.txt
```

The auditor identifies the world-write permission.

### 2. World-readable objects

Non-directory objects with the world-read bit set are flagged for review.

Example:

```bash
chmod 644 document.txt
```

World-readable access is not necessarily insecure. Many system files and public resources are intentionally readable by everyone.

### 3. SUID permissions

The Set User ID bit can cause an executable to run with the effective user ID of its owner.

Example test mode:

```bash
chmod 4755 suid_test
```

The auditor flags the SUID bit for further investigation.

### 4. SGID permissions

The Set Group ID bit can affect the effective group ID of an executable or group inheritance behavior on a directory.

Example test mode:

```bash
chmod 2755 sgid_test
```

The auditor flags the SGID bit for review.

**Important:** SUID and SGID permissions are not automatically vulnerabilities. Legitimate system programs use these bits, so findings must be evaluated in context.

## 🧪 Testing

The project can be tested using a controlled lab directory rather than changing permissions on system files.

Create the test environment:

```bash
mkdir -p tests/lab/open_directory
touch tests/lab/public.txt
touch tests/lab/secret.txt

chmod 777 tests/lab/open_directory
chmod 666 tests/lab/public.txt
chmod 600 tests/lab/secret.txt
```

Run the auditor:

```bash
./permission_auditor.sh tests/lab
echo "Exit code: $?"
```

Expected behavior:

- `open_directory` is flagged as world-writable.
- `public.txt` is flagged as world-writable and world-readable.
- `secret.txt` should not trigger these permission rules.
- The exit code should be `1` when findings are detected.

To test special permission bits:

```bash
touch tests/lab/suid_test
touch tests/lab/sgid_test

chmod 4755 tests/lab/suid_test
chmod 2755 tests/lab/sgid_test

./permission_auditor.sh tests/lab
```

These test files are used to verify permission detection; they are not intended to be privileged programs.

## 🚦 Exit Codes

| Code | Meaning |
|---|---|
| `0` | Audit completed without findings |
| `1` | Audit completed with findings |
| `2` | Invalid arguments or usage |
| `3` | Operational error |

These exit codes make it possible to integrate the auditor into shell scripts and other automation workflows.

## 🔒 Security Considerations

- The tool is intended for defensive security auditing and Linux administration.
- It does not intentionally change file permissions or ownership.
- Symbolic links are not followed during filesystem traversal.
- Findings indicate potentially risky configurations, not confirmed vulnerabilities.
- Access checks and filesystem metadata can change while a scan is running.
- Audit coverage may be incomplete when permissions or filesystem errors prevent inspection.
- Report destinations should be chosen carefully, particularly when auditing untrusted directory trees.

This is an educational security tool and should not be treated as a complete compliance scanner
