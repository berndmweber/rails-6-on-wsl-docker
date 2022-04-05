#!/bin/bash
set -e

# install missing gems
bundle check || bundle install --jobs 20 --retry 5

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
