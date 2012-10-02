eval `ssh-agent -s`
ssh-add
rvm use 1.9.3@hangman_extreme
git remote add staging git@heroku.com:tryhangmanleague.git; true
git push staging master --verbose
heroku run rake db:migrate --app tryhangmanleague
heroku run rake airbrake:deploy TO=staging --app tryhangmanleague
