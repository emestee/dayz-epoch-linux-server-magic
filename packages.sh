#!/bin/sh
apt-get install perl screen mysql-server mysql-client libjson-xs-perl libdbd-mysql-perl git unworkable

[ "$(uname -m)" == "x86_64" ] && apt-get install lib32stdc++6