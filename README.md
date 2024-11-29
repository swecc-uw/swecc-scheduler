# swecc-scheduler

Schedule recurring tasks

# env

There are no secrets here, so here are the correct env variables to use

```bash
# .env.local
export DOCKER_NETWORK=swecc-server_default
export SCHEDULER_CONTAINER_NAME=scheduler-dev
export SCHEDULER_LOG_DIR=/app/logs
export SCHEDULER_TEMP_DIR=/app/tmp
export SCHEDULER_BASE_URL=http://swecc-server-web-1:8000
export SCHEDULER_REQUEST_TIMEOUT=5
export SCHEDULER_MAX_RETRIES=3
export SCHEDULER_RETRY_DELAY=1
```

```bash
# .env.prod
export DOCKER_NETWORK=swag-network
export SCHEDULER_CONTAINER_NAME=scheduler-prod
export SCHEDULER_LOG_DIR=/var/log/swecc-scheduler
export SCHEDULER_TEMP_DIR=/tmp/scheduler
export SCHEDULER_BASE_URL=http://swecc-server-be-container:8000
export SCHEDULER_REQUEST_TIMEOUT=10000000
export SCHEDULER_MAX_RETRIES=1
export SCHEDULER_RETRY_DELAY=100
```

# local
```bash
docker build -t task-scheduler .

# replace with your own local network
docker run --name scheduler --network swecc-server_default task-scheduler
```

# prod
```bash
docker build -t task-scheduler .
docker run --name scheduler --network swag-network task-scheduler