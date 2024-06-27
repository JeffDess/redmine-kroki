#!/bin/bash

NEEDS_UP=$(docker ps --format '{{.Names}}' | grep -c 'redmine_kroki_test')

if [ "$NEEDS_UP" -lt 6 ]; then
  docker compose -f compose.test.yml up -d
  echo "Server is starting up..."
  sleep 10
fi

docker compose -f compose.test.yml exec redmine sh -c "\
  bundle install && \
  bin/rails db:migrate RAILS_ENV=test && \
  bundle exec rake test TEST=plugins/redmine_kroki/test/redmine_kroki_helper.rb
"

CODE=$?

if [ "$1" = '--down' ]; then
  docker compose -f compose.test.yml down
fi

exit "$CODE"
