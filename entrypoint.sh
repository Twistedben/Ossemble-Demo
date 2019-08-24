#!/bin/sh
# https://stackoverflow.com/a/38732187/1935918
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /tmp/pids/server.pid

#RAILS_ENV=development NODE_ENV=development bundle exec rails assets:precompile
#bundle exec rake db:schema:load 2>/dev/null || bundle exec rake db:setup

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"