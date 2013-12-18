#!/bin/sh
git remote add staging git@heroku.com:tryhangmanleague.git
heroku maintenance:on --app tryhangmanleague && \
git push staging badges:master --force --verbose && \
heroku run rake db:migrate --app tryhangmanleague && \
heroku run rake airbrake:deploy TO=staging --app tryhangmanleague && \
heroku maintenance:off --app tryhangmanleague
