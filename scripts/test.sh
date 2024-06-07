#!/bin/bash

NEEDS_UP=$(docker ps --format '{{.Names}}' | grep -c 'redmine_kroki_test')

if [ "$NEEDS_UP" -lt 7 ]; then
  docker compose -f compose.test.yml up -d
fi

docker compose -f compose.test.yml \
  exec redmine bundle exec rake test \
  TEST=plugins/redmine_kroki/test/redmine_kroki_helper.rb

CODE=$?

if [ "$1" = '--down' ]; then
  docker compose -f compose.test.yml down
fi

exit "$CODE"
