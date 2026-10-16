#!/bin/bash

docker compose -f compose.test.yml up -d

docker compose -f compose.test.yml run redmine sh -c "\
  bundle install && \
  bin/rails db:migrate RAILS_ENV=test && \
  bin/rails test plugins/redmine_kroki/test
"
