git remote add production git@heroku.com:mxithangmanleague.git
heroku maintenance:on --app mxithangmanleague && \
git push production master && \
heroku run rake db:migrate --app mxithangmanleague && \
heroku run rake airbrake:deploy TO=production --app mxithangmanleague && \
heroku maintenance:off --app mxithangmanleague