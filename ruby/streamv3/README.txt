run this using
thin -R config.ru -a 192.168.0.2 -p 1234 start

setting up password auth https://www.postgresql.org/docs/current/auth-password.html

create role <username> with login password '<password>'
alter user <username> password '<new password>';
