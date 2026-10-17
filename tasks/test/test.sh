#!/usr/bin/env bash
# shellcheck disable=SC2154

running=$(docker ps --format '{{.Names}}' | grep -c 'redmine_kroki_test' || true)

if [ "$running" -lt 6 ]; then
  docker compose -f compose.test.yml up -d
  info "Server is starting up..."
  sleep 12
fi

code=0
docker compose -f compose.test.yml exec redmine sh -c "
  bundle install &&
  bin/rails db:migrate RAILS_ENV=test &&
  bin/rails test plugins/redmine_kroki/test
" || code=$?

if [ "$down" = true ]; then
  docker compose -f compose.test.yml down
fi

exit "$code"
