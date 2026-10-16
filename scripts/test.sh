#!/bin/bash

NEEDS_UP=$(docker ps --format '{{.Names}}' | grep -c 'redmine_kroki_test')

if [ "$NEEDS_UP" -lt 6 ]; then
  docker compose -f compose.test.yml up -d
  echo "Server is starting up..."
  sleep 12
fi

docker compose -f compose.test.yml exec redmine sh -c "\
  bundle install && \
  bin/rails db:migrate RAILS_ENV=test && \
  bin/rails test plugins/redmine_kroki/test
"

CODE=$?

if [ "$1" = '--down' ]; then
  docker compose -f compose.test.yml down
fi

exit "$CODE"
