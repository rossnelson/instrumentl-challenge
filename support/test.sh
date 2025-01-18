#!/usr/bin/env bash

set -e

while ! docker exec -t safebite-pg-1 pg_isready -U postgres -h localhost -p 5432; do
    echo "Waiting for postgres container..."
    sleep 2;
done

pushd ./app

bundle exec rake db:create RAILS_ENV=test
bundle exec rake db:migrate RAILS_ENV=test

bundle exec rubocop

bundle exec rspec

popd
