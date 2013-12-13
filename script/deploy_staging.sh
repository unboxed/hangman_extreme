#!/bin/sh
git remote add staging git@heroku.com:tryhangmanleague.git
heroku maintenance:on --app tryhangmanleague && \
<<<<<<< HEAD
git push staging badges:master --force --verbose && \
=======
git push staging badges:master --verbose && \
>>>>>>> a3e4f3ca317d2275f67fa4042e56235b0227551f
heroku run rake db:migrate --app tryhangmanleague && \
heroku run rake airbrake:deploy TO=staging --app tryhangmanleague && \
heroku maintenance:off --app tryhangmanleague
