git clean -fd

rvm use 1.9.3@hangman_extreme
bundle install --without development --frozen

cp -f config/database_jenkins.yml config/database.yml
RAILS_ENV=test bundle exec rake log:clear db:drop db:create db:migrate
rm -rf coverage
RAILS_ENV=test bundle exec rake log:clear
RAILS_ENV=test EXCLUDE_REDIS_SPECS=true COVERAGE=on bundle exec rake spec:unit
RAILS_ENV=test MXIT_CLIENT_ID=1 SHINKA_AUID=1 GA_TRACKING_CODE=1 bundle exec rspec -b spec/requests