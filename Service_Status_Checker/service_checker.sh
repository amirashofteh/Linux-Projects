#!/usr/bin/env bash
# Service Status Checker
# Version 1.5

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/service_checker.log"

if ! mkdir -p "$LOG_DIR"; then
    echo "[ERROR] Cannot create log directory: $LOG_DIR" >&2
    exit 2
fi

log_result() {
    local SERVICE_NAME="$1"
    local SERVICE_STATE="$2"
    local TIMESTAMP

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S') || return 1

    if ! printf '%s | %s | %s\n' \
        "$TIMESTAMP" "$SERVICE_NAME" "$SERVICE_STATE" >> "$LOG_FILE"; then
        echo "[ERROR] Cannot write to log file: $LOG_FILE" >&2
        return 1
    fi
}
record_result() {
    local SERVICE_NAME="$1"
    local SERVICE_STATE="$2"

    if ! log_result "$SERVICE_NAME" "$SERVICE_STATE"; then
        EXIT_CODE=2
    fi
}
echo "===================================="
echo "       Service Status Checker"
echo "===================================="

if [[ "$#" -eq 0 ]]; then
    echo "[ERROR] No service names provided."
    echo "Usage: $0 <service_name> [service_name ...]"
    exit 2
fi

EXIT_CODE=0

for SERVICE in "$@"; do
    echo
    echo "Checking service: $SERVICE"

    UNIT="${SERVICE}.service"

    LOAD_STATE=$(systemctl show "$UNIT" \
        --property=LoadState --value 2>/dev/null)

    if [[ "$LOAD_STATE" == "not-found" || -z "$LOAD_STATE" ]]; then
    echo "[ERROR] Service unit not found: $UNIT"
    record_result "$SERVICE" "not-found"
    EXIT_CODE=2
    continue
    fi

    STATE=$(systemctl show "$UNIT" \
        --property=ActiveState --value 2>/dev/null)

    case "$STATE" in
        active)
            echo "[OK] $SERVICE is active."
	    record_result "$SERVICE" "$STATE"
            ;;
        inactive)
            echo "[WARNING] $SERVICE is inactive."
            record_result "$SERVICE" "$STATE"
            [[ "$EXIT_CODE" -eq 2 ]] || EXIT_CODE=1
            ;;
        failed)
            echo "[CRITICAL] $SERVICE has failed."
            record_result "$SERVICE" "$STATE"
            [[ "$EXIT_CODE" -eq 2 ]] || EXIT_CODE=1
            ;;
        activating)
            echo "[INFO] $SERVICE is starting."
            record_result "$SERVICE" "$STATE"
            [[ "$EXIT_CODE" -eq 2 ]] || EXIT_CODE=1
            ;;
        deactivating)
            echo "[INFO] $SERVICE is stopping."
            record_result "$SERVICE" "$STATE"
            [[ "$EXIT_CODE" -eq 2 ]] || EXIT_CODE=1
            ;;
        reloading)
            echo "[INFO] $SERVICE is reloading."
            record_result "$SERVICE" "$STATE"
            [[ "$EXIT_CODE" -eq 2 ]] || EXIT_CODE=1
            ;;
        *)
            echo "[UNKNOWN] Could not determine service state: $STATE"
            record_result "$SERVICE" "$STATE"
            [[ "$EXIT_CODE" -eq 2 ]] || EXIT_CODE=1
            ;;
    esac
done

echo
echo "Service check completed."
exit "$EXIT_CODE"
