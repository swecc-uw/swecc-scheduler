#!/bin/bash

source "/app/config/settings.sh"

# every 5 minute
health_check_schedule="*/5 * * * *"
health_check_command="bash -c 'echo \"[\$(date +\"%Y-%m-%d %H:%M:%S\")] [HEALTH] \$(curl $BASE_URL/health/)\" >> $LOG_DIR/health_check.log'"

# every 6 hours
update_leetcode_stats_schedule="0 */6 * * *"
update_leetcode_stats_command="curl -X POST -H 'Content-Type: application/json' -d '{\"command\": \"update_leetcode_stats\"}' $BASE_URL/admin/commands --header 'Authorization $API_KEY'"

# every 6 hours, offset by 3 hours
update_github_stats_schedule="0 3-23/6 * * *"
update_github_stats_command="curl -X POST -H 'Content-Type: application/json' -d '{\"command\": \"update_github_stats\"}' $BASE_URL/admin/commands --header 'Authorization $API_KEY'"

# export all tasks
TASKS="health_check update_leetcode_stats update_github_stats"