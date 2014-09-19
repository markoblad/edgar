This is a simple rails 3.2 app for grabbing and parsing XBRL files (and a few others) from the SEC's edgar site.

A few useful commands:

- to clone the repo from github:
git clone https://github.com/markoblad/edgar.git

- install version of rails for app
gem install rails -v '3.2.19'

or use rbenv or rvm

- install gems
bundle install

- start a local development server on http://localhost:3000
rails server

- start a development console
rails console

- add role to database changing "edgarxbrl" to your application name
psql postgres;
CREATE ROLE edgarxbrl;
ALTER USER edgarxbrl WITH LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION;

- create the database
rake db:create:all


To understand how SEC filing exhibits are classified see Reg SK here: http://www.law.cornell.edu/cfr/text/17/229.601




