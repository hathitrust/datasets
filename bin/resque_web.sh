#!/usr/bin/env bash
bundle exec resque-web $(dirname $0)/../config/resque-web.rb -p 9231 -F "$@"