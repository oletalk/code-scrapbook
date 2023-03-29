if you have installed libpq on the Mac, run this first before bundle install
gem install pg -- --with-opt-dir="/usr/local/opt/libpq"

the tables are in the bills schema. in psql, \d will only list the tables in the public schema.
to look at the tables in the bills schema, do \dt bills.*