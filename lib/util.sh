#!/bin/bash

log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

validate_cron() {
    local schedule="$1"
    # cron regex
    if ! [[ "$schedule" =~ ^[0-9*,-/]+[[:space:]]+[0-9*,-/]+[[:space:]]+[0-9*,-/]+[[:space:]]+[0-9*,-/]+[[:space:]]+[0-9*,-/]+$ ]]; then
        return 1
    fi
    return 0
}

create_task_file() {
    local task_name="$1"
    local command="$2"

    # ensure TASK_TEMP_DIR exists
    if [[ -z "$TASK_TEMP_DIR" ]]; then
        log_info "Error: TASK_TEMP_DIR is not set"
        exit 1
    fi

    mkdir -p "$TASK_TEMP_DIR"
    local tmp_file="$TASK_TEMP_DIR/${task_name}.sh"
    
    {
        echo "#!/bin/bash"
        echo "set -euo pipefail"
        echo "source /app/.env"
        echo "source /app/config/settings.sh"
        echo "$command"
    } > "$tmp_file"

    chmod +x "$tmp_file"
    echo "$tmp_file"
}

register_task() {
    local schedule="$1"
    local task_file="$2"
    local task_name="$3"
    
    local task_marker="# SCHEDULER_TASK: $task_name"
    local log_file="$LOG_DIR/${task_name}.log"

    # remove existing task if present
    crontab -l 2>/dev/null | grep -v "$task_marker" | crontab -

    # add new task with logging and error handling
    (crontab -l 2>/dev/null; echo "$schedule $task_file >> $log_file 2>&1 $task_marker") | crontab -

    # verify task was added
    if ! crontab -l | grep -q "$task_marker"; then
        log_info "Error: Failed to register task '$task_name'"
        return 1
    fi
}

remove_all_tasks() {
    # remove cron jobs
    crontab -l 2>/dev/null | grep -v "SCHEDULER_TASK:" | crontab -

    # clean up task files if TASK_TEMP_DIR is set and exists
    if [[ -n "$TASK_TEMP_DIR" && -d "$TASK_TEMP_DIR" ]]; then
        rm -f "$TASK_TEMP_DIR"/*.sh
    fi

    log_info "All tasks removed"
}