FROM alpine:3.18

# install required packages
RUN apk add --no-cache \
  bash \
  curl \
  tzdata \
  coreutils \
  dcron

# create directories
RUN mkdir -p /app/bin /app/lib /app/schedule /app/config

# copy all application files
COPY bin/ /app/bin/
COPY lib/ /app/lib/
COPY schedule/ /app/schedule/
COPY config/ /app/config/
COPY .env.local /app/.env.local
COPY .env.prod /app/.env.prod


RUN if [ -f .env.secret ]; then cp .env.secret /app/.env.secret; fi

COPY entrypoint.sh /app/entrypoint.sh

# make scripts executable
RUN chmod +x /app/bin/*.sh /app/entrypoint.sh

# set working directory
WORKDIR /app

# use environment arg to determine which env file to load
ARG ENV=local
ENV ENV=${ENV}

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/app/bin/start.sh"]