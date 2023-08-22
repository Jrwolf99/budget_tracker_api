# README

Budget Tracker API

### Setting up the app (macOS)
 1) Install ruby 3.1.3 - use [asdf](https://asdf-vm.com/).
 2) Install [Postgres](https://www.postgresql.org/).
 3) Run `bundle install`.
 4) Setup the database `rake db:create` (make sure to have a postgres server running on port 5432).
 5) Setup the schema `rake db:schema:load`.
 6) Run the seeds `rake db:seed`.