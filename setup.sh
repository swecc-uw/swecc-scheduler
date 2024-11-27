#!/bin/bash

IMAGE_NAME="$1"
if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image_name>"
    exit 1
fi

LOG_FILE="/var/log/scheduled-tasks.log"

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

if [ ! -f "${LOG_FILE}" ]; then
    touch "${LOG_FILE}"
    chmod 666 "${LOG_FILE}"
fi

DOCKER_PATH=$(which docker)
if [ -z "$DOCKER_PATH" ]; then
    echo "Docker is not installed or not found in PATH."
    exit 1
fi

CONTAINER_ID=$("$DOCKER_PATH" ps --filter ancestor=$IMAGE_NAME -q)
if [ -z "$CONTAINER_ID" ]; then
    echo "No container found running with image: $IMAGE_NAME"
    exit 1
fi

TASK_NAMES=(
    "health_check"
    "update_github_leaderboard"
    "update_leetcode_leaderboard"
)

TASK_SCHEDULES=(    # every min
    "* * * * *"
    "0 0 * * *"     # midnight daily
    "0 0 * * *"     # midnight daily
)

TASK_COMMANDS=(
    "echo '[\$(date)] Running health check' >> $LOG_FILE && python server/manage.py health_check >> $LOG_FILE 2>&1"
    "echo '[\$(date)] Updating GitHub leaderboard' >> $LOG_FILE && python server/manage.py update_github_stats >> $LOG_FILE 2>&1"
    "echo '[\$(date)] Updating LeetCode leaderboard' >> $LOG_FILE && python server/manage.py update_leetcode_stats >> $LOG_FILE 2>&1"
)

TEMP_CRON=$(mktemp)
crontab -l > "$TEMP_CRON" 2>/dev/null

sed -i.bak '/# BEGIN SCHEDULED TASKS/,/# END SCHEDULED TASKS/d' "$TEMP_CRON"

echo "# BEGIN SCHEDULED TASKS" >> "$TEMP_CRON"
for i in "${!TASK_NAMES[@]}"; do
    echo "${TASK_SCHEDULES[$i]} $DOCKER_PATH exec $CONTAINER_ID /bin/bash -c 'cd /app && ${TASK_COMMANDS[$i]}'" >> "$TEMP_CRON"
done
echo "# END SCHEDULED TASKS" >> "$TEMP_CRON"

crontab "$TEMP_CRON"
rm "$TEMP_CRON" "$TEMP_CRON.bak" 2>/dev/null

echo "[$(date)] Tasks installed successfully:" >> "$LOG_FILE"
crontab -l >> "$LOG_FILE"

echo -e "\nTo remove all tasks later, run:"
echo "sudo crontab -r  # removes everything"
echo "- or -"
echo "sudo crontab -l | grep -v \"# BEGIN SCHEDULED TASKS\" | grep -v \"# END SCHEDULED TASKS\" | sudo crontab -  # removes just these tasks"
