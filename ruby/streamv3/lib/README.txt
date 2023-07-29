run this using
bundle exec puma

setting up password auth https://www.postgresql.org/docs/current/auth-password.html

create role <username> with login password '<password>'
alter user <username> password '<new password>';
