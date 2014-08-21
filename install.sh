#!/bin/bash

. CONFIGURATION

fail () {
    echo "***FAILED*** $1"
    exit 1
}

help () {
    echo "Syntax: ./install.sh <command>"
    echo
    echo "Available commands are:"
    echo
    echo "* all - Download and install everything; use this, everything else is steps in case stuff breaks"
    echo "* dl_epoch - Download Epoch client files (torrent)"
    echo "* dl_steamcmd - Download and unpack SteamCmd"
    echo "* dl_game - Download ARMA II, ARMA II: OA and the beta packages using SteamCMD"
    echo "* dl_server - Download Linux server binaries"
    echo "* dl_tools - Download denisio's server tools"
    echo "* compose - Combine everything into a working server directory"
    echo "* sql - Initialize the SQL database"
    echo "* clean - Remove unneeded garbage from the server directory"
    echo "* reset - Start from scratch (destroys the server directory and the SQL database)"
    echo
    echo "Server will be installed into ${SERVER_PATH}"
}



all () {
    [ -d "$SERVER_PATH" ] && fail "Safety: server directory $SERVER_PATH already exists, this procedure will destroy it; exiting."

    mkdir -p $CACHE $SERVER_PATH 

    echo "Installing Steam"
    dl_steamcmd
    echo "Downloading and installing the game - long"
    dl_game
    echo "Downloading the server binaries"
    dl_server
    echo "Downloading the server tools"
    dl_tools
    echo "Downloading and installing the Epoch client file via bittorrent - long"
    dl_epoch
    echo "Here be dragons! Composing the rest."
    compose
    echo "Initializing the database"
    sql
    echo "Cleanup"
    clean
    echo "All done!"
}

dl_steamcmd () {
    curl -s -o $CACHE/steamcmd_linux.tar.gz $STEAMCMD_URL || fail "Unable to download SteamCmd"
    mkdir steamcmd -p
    tar xzf $CACHE/steamcmd_linux.tar.gz -C steamcmd
}

dl_game () {
    steamcmd/steamcmd.sh +login $STEAM_USERNAME $STEAM_PASSWORD +runscript ../script.steam || fail "SteamCmd game installation failed"
}

dl_server () {
    a2oa_tarball=$(basename $ARMA2_SERVER_URL)
    curl -s -o $CACHE/${a2oa_tarball} $ARMA2_SERVER_URL || fail "Unable to download the server tarball from $ARMA2_SERVER_URL"

    mkdir -p arma2-server
    tar xjf $CACHE/${a2oa_tarball} -C arma2-server || fail "Unable to extract the server tarball"
}

dl_tools () {
    git submodule init
    git submodule update || exit "Failed to update git submodules"
}

dl_epoch () {
    curl -s -o $CACHE/${EPOCH_CLIENT_TARBALL}.torrent $EPOCH_CLIENT_URL | fail "Epoch client torrent file unavailable"
    pushd $CACHE > /dev/null
    unworkable ${EPOCH_CLIENT_TARBALL}.torrent || fail "Unable to download the Epoch client file from bittorrent"
    popd > /dev/null
}

extract_epoch () {
    echo Installing Epoch client files
    7zr x -o${SERVER_PATH} $CACHE/${EPOCH_CLIENT_TARBALL} > /dev/null || fail "Unable to extract ${EPOCH_CLIENT_TARBALL}, file corrupt/disk full?"
}

clean () {
    find $SERVER_PATH -iname '*.pdf' -delete
    find $SERVER_PATH -iname '*.exe' -delete
    find $SERVER_PATH -iname '*.vdf' -delete
    find $SERVER_PATH -iname '*.cmd' -delete
    find $SERVER_PATH -iname '*.dll' -delete
    find $SERVER_PATH -iname '*.bat' -delete
    rm -rf $SERVER_PATH/*.txt $SERVER_PATH/dll $SERVER_PATH/besetup $SERVER_PATH/directx

    find $SERVER_PATH -type f -exec chmod a-x {} \;
    chmod u+x $SERVER_PATH/epoch $SERVER_PATH/*.pl $SERVER_PATH/*.sh
}

compose () {
    extract_epoch

    echo "Applying downcasing, dog bless"
    find $SERVER_PATH -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;

    echo "Installing denisio's Linux tools"
    cp Dayz-Epoch-Linux-Server/*.pl $SERVER_PATH
    cp Dayz-Epoch-Linux-Server/*.sh $SERVER_PATH
    cp -r Dayz-Epoch-Linux-Server/cache $SERVER_PATH
    cp -r Dayz-Epoch-Linux-Server/cfgdayz $SERVER_PATH
    cp -r Dayz-Epoch-Linux-Server/@dayz_epoch_server $SERVER_PATH
    cp -r Dayz-Epoch-Linux-Server/expansion $SERVER_PATH
    cp -r Dayz-Epoch-Linux-Server/keys $SERVER_PATH
    cp -r Dayz-Epoch-Linux-Server/mpmissions $SERVER_PATH

    echo "Installing server binaries"
    cp arma2-server/server $SERVER_PATH/epoch
    cp -r arma2-server/expansion $SERVER_PATH
}

sql () {
    mysqladmin -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASSWORD} create epoch || fail "Unable to create the database; invalid user/password?"
    mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASSWORD} -e "GRANT ALL PRIVILEGES ON epoch.* TO 'dayz'@'localhost' IDENTIFIED BY 'dayz';"
    cat Dayz-Epoch-Linux-Server/database.sql Dayz-Epoch-Linux-Server/v1042update.sql Dayz-Epoch-Linux-Server/v1042a_update.sql Dayz-Epoch-Linux-Server/v1051update.sql | mysql -udayz -pdayz epoch
}

reset () {
    rm -rf $SERVER_PATH
    yes|mysqladmin -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASSWORD} drop epoch > /dev/null
    
}
[ "$1" = "" ] && { 
    help
    exit
}

$*
echo End.
exit 0
