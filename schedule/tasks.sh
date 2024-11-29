#!/bin/bash

source "$(dirname "$0")/../config/settings.sh"

# every minute
health_check_schedule="* * * * *"
# bash -c to ensure date is evaluated at runtime
health_check_command="bash -c 'echo \"[\$(date +\"%Y-%m-%d %H:%M:%S\")] [HEALTH] \$(curl $BASE_URL/health/)\" >> $LOG_DIR/health_check.log'"

# export all tasks
TASKS="health_check"