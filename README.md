Flexo
=====

The Unboxed Hangman game for the MXit platform (and hopefully soon facebook)

Developer setup
===============

bundle install

Bundle
------

Set yourself up a gemset and Bundle

    bundle install

Prepare the database

    rake db:setup
    rake db:migrate
    rake db:seed


Postgres
--------

The database Flexo uses is PostgreSQL, so you'll need to have that on your system. The easiest way is to `brew` it.

    brew update
    brew install postgresql

If this was your first time installing postgres, after the install you can create your first database with:

    initdb /usr/local/var/postgres

Then configure your LaunchAgent to automatically start the postgres server on login:

    mkdir -p ~/Library/LaunchAgents
    cp /usr/local/Cellar/postgresql/9.1.4/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
    launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist

You should now be able to access the CLI with `psql postgres`

*If you have trouble with Postgres, remove it and try again with* `brew rm postgresql --force`