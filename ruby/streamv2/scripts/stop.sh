#!/usr/bin/env bash
thin -R config.ru -a 192.168.0.2 -p 2345 -l /var/tmp/streamer_server.web.log -P /var/tmp/pid-mp3server.ss.pid stop
thin -R config2.ru -a 192.168.0.2 -p 2351 -l /var/tmp/db_server.web.log -P /var/tmp/pid-mp3server.db.pid stop

