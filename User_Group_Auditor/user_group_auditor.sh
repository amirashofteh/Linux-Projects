#!/usr/bin/env bash
# Project: Linux User and Group Auditor
# Version: 0.3.0

set -o nounset
set -o pipefail

MIN_UID=1000
MAX_UID=59999
OUTPUT_FILE=""
REPORT_FORMAT="txt"

SHOW_USERS=false
SHOW_GROUPS=false
RUN_AUDIT=false

SCRIPT_NAME="${0##*/}"
declare -a REPORT_ROWS=()
FINDINGS=0

usage() {
    cat <<EOF
$SCRIPT_NAME - Linux User and Group Auditor v0.3.0

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help          Show help
  -u, --users         List user accounts
  -g, --groups        List groups and memberships
  -a, --audit         Run security audit
  -f, --format FORMAT Report format: txt or csv
  -o, --output FILE   Save report to a file
      --min-uid UID   Minimum regular-user UID
      --max-uid UID   Maximum regular-user UID

Examples:
  $SCRIPT_NAME --users
  $SCRIPT_NAME --groups
  $SCRIPT_NAME --audit
  $SCRIPT_NAME --audit --format csv --output reports/audit.csv
EOF
}

error() {
    printf 'ERROR: %s\n' "$*" >&2
}

is_uint() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

check_dependencies() {
    local cmd
    for cmd in getent awk mkdir dirname date; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error "Required command not found: $cmd"
            return 1
        fi
    done
}

parse_arguments() {
    while (($# > 0)); do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -u|--users) SHOW_USERS=true ;;
            -g|--groups) SHOW_GROUPS=true ;;
            -a|--audit) RUN_AUDIT=true ;;
            -f|--format)
                if (($# < 2)) || [[ -z "$2" ]]; then
                    error "Missing value for $1"
                    return 2
                fi
                REPORT_FORMAT="$2"
                shift
                ;;
            -o|--output)
                if (($# < 2)) || [[ -z "$2" ]]; then
                    error "Missing output filename"
                    return 2
                fi
                OUTPUT_FILE="$2"
                shift
                ;;
            --min-uid|--max-uid)
                local option="$1"
                if (($# < 2)) || ! is_uint "$2"; then
                    error "$option requires a non-negative integer"
                    return 2
                fi
                if ((${#2} > 9)); then
                    error "$option value is too large"
                    return 2
                fi
                if [[ "$option" == "--min-uid" ]]; then
                    MIN_UID=$((10#$2))
                else
                    MAX_UID=$((10#$2))
                fi
                shift
                ;;
            -*)
                error "Unknown option: $1"
                return 2
                ;;
            *)
                error "Unexpected argument: $1"
                return 2
                ;;
        esac
        shift
    done

    if ((MIN_UID > MAX_UID)); then
        error "--min-uid cannot exceed --max-uid"
        return 2
    fi

    if [[ "$REPORT_FORMAT" != "txt" && "$REPORT_FORMAT" != "csv" ]]; then
        error "Format must be txt or csv"
        return 2
    fi

    if [[ -n "$OUTPUT_FILE" ]]; then
        case "$REPORT_FORMAT:$OUTPUT_FILE" in
            txt:*.csv|csv:*.txt)
                error "Output extension does not match format"
                return 2
                ;;
        esac
    fi

    if [[ "$SHOW_USERS" == false &&
          "$SHOW_GROUPS" == false &&
          "$RUN_AUDIT" == false ]]; then
        RUN_AUDIT=true
    fi
}

classify_uid() {
    local uid="$1"
    if ((uid == 0)); then
        printf 'PRIVILEGED'
    elif ((uid >= MIN_UID && uid <= MAX_UID)); then
        printf 'REGULAR'
    else
        printf 'SYSTEM'
    fi
}

add_row() {
    REPORT_ROWS+=("$1"$'\t'"$2"$'\t'"$3"$'\t'"$4"$'\t'"$5"$'\t'"$6")
}

list_users() {
    local username password uid gid gecos home shell class

    printf '\n=== USER ACCOUNTS ===\n'
    printf '%-20s %-8s %-8s %-12s %-25s %s\n' \
        USERNAME UID GID CLASS SHELL HOME

    while IFS=: read -r username password uid gid gecos home shell; do
        [[ "$uid" =~ ^[0-9]+$ ]] || continue
        class=$(classify_uid "$uid")
        printf '%-20s %-8s %-8s %-12s %-25s %s\n' \
            "$username" "$uid" "$gid" "$class" "$shell" "$home"
        add_row USER "$username" "$uid" "$class" "$shell" "$home"
    done < <(getent passwd)
}

list_groups() {
    local group password gid members username user_password uid
    local primary_gid gecos home shell primary combined member
    local -a member_array=()

    printf '\n=== GROUPS AND MEMBERSHIPS ===\n'
    printf '%-25s %-10s %s\n' GROUP GID MEMBERS

    while IFS=: read -r group password gid members; do
        primary=""
        combined=""

        while IFS=: read -r username user_password uid primary_gid \
            gecos home shell; do
            if [[ "$primary_gid" == "$gid" ]]; then
                [[ -n "$primary" ]] && primary+=","
                primary+="$username"
            fi
        done < <(getent passwd)

        combined="$primary"

        if [[ -n "$members" ]]; then
            IFS=',' read -r -a member_array <<< "$members"
            for member in "${member_array[@]}"; do
                [[ -n "$member" ]] || continue
                case ",$combined," in
                    *,"$member",*) ;;
                    *)
                        [[ -n "$combined" ]] && combined+=","
                        combined+="$member"
                        ;;
                esac
            done
        fi

        printf '%-25s %-10s %s\n' "$group" "$gid" "$combined"
        add_row GROUP "$group" "$gid" "$combined" "" ""
    done < <(getent group)
}

audit_accounts() {
    local username password uid gid gecos home shell shell_base
    local found valid_shell
    local -a valid_shells=()

    printf '\n=== ACCOUNT SECURITY AUDIT ===\n'

    if [[ -r /etc/shells ]]; then
        while IFS= read -r shell_base; do
            [[ "$shell_base" == /* ]] || continue
            valid_shells+=("$shell_base")
        done < /etc/shells
    fi

    while IFS=: read -r username password uid gid gecos home shell; do
        [[ "$uid" =~ ^[0-9]+$ ]] || continue

        if ((uid == 0)) && [[ "$username" != root ]]; then
            printf '[HIGH] Non-root account has UID 0: %s\n' "$username"
            add_row FINDING "$username" "$uid" HIGH \
                "Non-root account has UID 0" "$shell"
            ((FINDINGS += 1))
        fi

        if [[ -z "$shell" ]]; then
            printf '[MEDIUM] Empty login shell: %s\n' "$username"
            add_row FINDING "$username" "$uid" MEDIUM \
                "Missing login shell" ""
            ((FINDINGS += 1))
        elif [[ ! -f "$shell" || ! -x "$shell" ]]; then
            printf '[MEDIUM] Shell missing or not executable: %s (%s)\n' \
                "$username" "$shell"
            add_row FINDING "$username" "$uid" MEDIUM \
                "Shell missing or not executable" "$shell"
            ((FINDINGS += 1))
        elif ((uid >= MIN_UID && uid <= MAX_UID)); then
            shell_base="${shell##*/}"
            case "$shell_base" in
                nologin|false)
                    printf '[MEDIUM] Regular-range account uses non-login shell: %s\n' \
                        "$username"
                    add_row FINDING "$username" "$uid" MEDIUM \
                        "Regular-range account uses non-login shell" "$shell"
                    ((FINDINGS += 1))
                    ;;
                *)
                    found=false
                    for valid_shell in "${valid_shells[@]}"; do
                        if [[ "$shell" == "$valid_shell" ]]; then
                            found=true
                            break
                        fi
                    done
                    if ((${#valid_shells[@]} > 0)) &&
                       [[ "$found" == false ]]; then
                        printf '[LOW] Shell not listed in /etc/shells: %s (%s)\n' \
                            "$username" "$shell"
                        add_row FINDING "$username" "$uid" LOW \
                            "Shell not listed in /etc/shells" "$shell"
                        ((FINDINGS += 1))
                    fi
                    ;;
            esac
        fi

        if ((uid >= MIN_UID && uid <= MAX_UID)) &&
           [[ -n "$home" && "$home" != "/" &&
              "$home" != "/nonexistent" ]]; then
            if [[ ! -d "$home" ]]; then
                printf '[MEDIUM] Regular account home directory missing: %s (%s)\n' \
                    "$username" "$home"
                add_row FINDING "$username" "$uid" MEDIUM \
                    "Regular account home directory missing" "$home"
                ((FINDINGS += 1))
            fi
        fi
    done < <(getent passwd)

    printf '\nAccount audit complete. Findings so far: %s\n' "$FINDINGS"
}

audit_privileged_groups() {
    local group password gid members username user_password uid
    local primary_gid gecos home shell member is_member
    local -a group_members=()
    local -a groups_to_check=(sudo wheel docker shadow adm)

    printf '\n=== PRIVILEGED GROUP REVIEW ===\n'

    while IFS=: read -r group password gid members; do
        case " ${groups_to_check[*]} " in
            *" $group "*) ;;
            *) continue ;;
        esac

        group_members=()
        if [[ -n "$members" ]]; then
            IFS=',' read -r -a group_members <<< "$members"
        fi

        while IFS=: read -r username user_password uid primary_gid \
            gecos home shell; do
            is_member=false

            if [[ "$primary_gid" == "$gid" ]]; then
                is_member=true
            else
                for member in "${group_members[@]}"; do
                    if [[ "$member" == "$username" ]]; then
                        is_member=true
                        break
                    fi
                done
            fi

            if [[ "$is_member" == true ]]; then
                printf '[REVIEW] %s belongs to group %s (GID %s)\n' \
                    "$username" "$group" "$gid"
                add_row FINDING "$username" "$gid" REVIEW \
                    "Member of privileged group: $group" ""
                ((FINDINGS += 1))
            fi
        done < <(getent passwd)
    done < <(getent group)

    printf 'Privileged-group review complete.\n'
}

csv_escape() {
    local value="$1"
    value=${value//\"/\"\"}
    printf '"%s"' "$value"
}

export_report() {
    local row field first output_dir
    local -a fields=()

    [[ -n "$OUTPUT_FILE" ]] || return 0

    if [[ -e "$OUTPUT_FILE" && ! -f "$OUTPUT_FILE" ]]; then
        error "Output path is not a regular file"
        return 1
    fi

    output_dir=$(dirname -- "$OUTPUT_FILE")
    if ! mkdir -p -- "$output_dir"; then
        error "Cannot create output directory: $output_dir"
        return 1
    fi

    if [[ -e "$OUTPUT_FILE" && ! -w "$OUTPUT_FILE" ]]; then
        error "Output file is not writable: $OUTPUT_FILE"
        return 1
    fi

    if [[ "$REPORT_FORMAT" == csv ]]; then
        if ! {
            printf 'TYPE,NAME,UID_OR_GID,CLASS_OR_MEMBERS,DETAIL,EXTRA\n'
            for row in "${REPORT_ROWS[@]}"; do
                IFS=$'\t' read -r -a fields <<< "$row"
                first=true
                for field in "${fields[@]}"; do
                    [[ "$first" == true ]] || printf ','
                    csv_escape "$field"
                    first=false
                done
                printf '\n'
            done
        } > "$OUTPUT_FILE"; then
            error "Failed to write CSV report"
            return 1
        fi
    else
        if ! {
            printf 'Linux User and Group Auditor v0.3.0\n'
            printf 'Generated: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
            printf 'UID range: %s-%s\n\n' "$MIN_UID" "$MAX_UID"
            for row in "${REPORT_ROWS[@]}"; do
                printf '%s\n' "${row//$'\t'/ | }"
            done
        } > "$OUTPUT_FILE"; then
            error "Failed to write text report"
            return 1
        fi
    fi

    printf '\nReport saved to: %s\n' "$OUTPUT_FILE"
}

main() {
    check_dependencies || return 1
    parse_arguments "$@" || return $?

    printf 'Linux User and Group Auditor v0.3.0\n'
    printf 'UID classification range: %s-%s\n' "$MIN_UID" "$MAX_UID"

    [[ "$SHOW_USERS" == true ]] && list_users
    [[ "$SHOW_GROUPS" == true ]] && list_groups

    if [[ "$RUN_AUDIT" == true ]]; then
        audit_accounts
        audit_privileged_groups
        printf '\nTotal findings: %s\n' "$FINDINGS"
    fi

    export_report || return 1
}

main "$@"
