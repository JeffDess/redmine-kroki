#!/bin/bash

docker compose -f compose.test.yml up -d

docker compose -f compose.test.yml run redmine sh -c "\
  bundle install && \
  bin/rails db:migrate RAILS_ENV=test && \
  bundle exec rake test TEST=plugins/redmine_kroki/test/redmine_kroki_helper.rb
"
