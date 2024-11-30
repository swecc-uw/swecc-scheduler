#!/bin/bash

# network
NETWORK_NAME=${DOCKER_NETWORK}
# container
CONTAINER_NAME=${SCHEDULER_CONTAINER_NAME}
LOG_DIR=${SCHEDULER_LOG_DIR}
TASK_TEMP_DIR=${SCHEDULER_TEMP_DIR}
# request
BASE_URL=${SCHEDULER_BASE_URL}
REQUEST_TIMEOUT=${SCHEDULER_REQUEST_TIMEOUT}
MAX_RETRIES=${SCHEDULER_MAX_RETRIES}
RETRY_DELAY=${SCHEDULER_RETRY_DELAY}
API_KEY=${SCHEDULER_API_KEY}

required_vars=(
    "DOCKER_NETWORK"
    "SCHEDULER_CONTAINER_NAME"
    "SCHEDULER_LOG_DIR"
    "SCHEDULER_TEMP_DIR"
    "SCHEDULER_BASE_URL"
)

# validate env
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required environment variable $var is not set"
        exit 1
    fi
done