#!/bin/bash
apt-get install perl screen mysql-server mysql-client libjson-xs-perl libdbd-mysql-perl git ctorrent curl p7zip

[ `uname -m` == 'x86_64' ] && apt-get install lib32stdc++6
