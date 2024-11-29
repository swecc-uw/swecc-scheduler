#!/bin/bash

# load all
source "$(dirname "$0")/../config/settings.sh"
source "$(dirname "$0")/../lib/util.sh"
source "$(dirname "$0")/../schedule/tasks.sh"
source "$(dirname "$0")/../.env"

# clean up any existing tasks
remove_all_tasks

# create log directory
mkdir -p "$LOG_DIR"

# register all task
for task in $TASKS; do
    schedule_var="${task}_schedule"
    command_var="${task}_command"
    
    schedule="${!schedule_var}"
    command="${!command_var}"
    
    if ! validate_cron "$schedule"; then
        log "Error: Invalid cron schedule for task '$task': $schedule"
        continue
    fi
    
    task_file=$(create_task_file "$task" "$command")
    register_task "$schedule" "$task_file" "$task"
    log "Registered task '$task' with schedule '$schedule'"
done

# keep container running
tail -f /dev/null