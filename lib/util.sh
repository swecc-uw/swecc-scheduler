#!/bin/bash

# Log message with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Validate cron expression
validate_cron() {
    local cron="$1"
    if ! crontab -l 2>/dev/null | grep -q "^$cron"; then
        if ! echo "$cron" | crontab -; then
            return 1
        fi
        crontab -r
    fi
    return 0
}

# Create a temporary file for a task
create_task_file() {
    local task_name="$1"
    local command="$2"
    mkdir -p "$TASK_TEMP_DIR"
    local tmp_file="$TASK_TEMP_DIR/${task_name}.sh"
    
    echo "#!/bin/bash" > "$tmp_file"
    echo "$command" >> "$tmp_file"
    chmod +x "$tmp_file"
    echo "$tmp_file"
}

# Register a task in crontab
register_task() {
    local cron="$1"
    local task_file="$2"
    local task_name="$3"
    
    local task_marker="# SCHEDULER_TASK: $task_name"
    crontab -l 2>/dev/null | grep -v "$task_marker" | crontab -
    (crontab -l 2>/dev/null; echo "$cron $task_file $task_marker") | crontab -
}

# Remove all scheduled tasks
remove_all_tasks() {
    crontab -l 2>/dev/null | grep -v "SCHEDULER_TASK:" | crontab -
    rm -f "$TASK_TEMP_DIR"/*.sh
    log "All tasks removed"
}