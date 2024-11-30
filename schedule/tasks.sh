#!/bin/bash

source "/app/config/settings.sh"

# every 5 minutes
health_check_schedule="*/5 * * * *"
health_check_command="curl -s -S -f \"$BASE_URL/health/\" -o /dev/null || echo \"[\$(date +\"%Y-%m-%d %H:%M:%S\")] [ERROR] Health check failed\""

# every 6 hours
update_leetcode_stats_schedule="0 */6 * * *"
update_leetcode_stats_command="curl -s -S -f -X POST -H 'Content-Type: application/json' -H 'Authorization: Api-Key ${API_KEY}' -d '{\"command\": \"update_leetcode_stats\"}' \"$BASE_URL/admin/command/\""

# every 6 hours, offset by 3 hours
update_github_stats_schedule="0 3-23/6 * * *"
update_github_stats_command="curl -s -S -f -X POST -H 'Content-Type: application/json' -H 'Authorization: Api-Key $API_KEY' -d '{\"command\": \"update_github_stats\"}' \"$BASE_URL/admin/command/\""

# export all tasks
TASKS="health_check update_leetcode_stats update_github_stats"