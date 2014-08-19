Automated DayZ Epoch Linux server _magic_ installer
===========================================

Current Epoch version: *1.0.5.1*

Current Arma 2 AO server engine: *1.63.112555* (e91456595c3380f853097e0c767e1d0e)

Current Arma 2 AO beta data files: *1.63.122548*

What is this?
-------------

This is a hands-free make-based automated installer for Dayz Epoch
game server. It automatically downloads all the required dependencies,
including the game binaries from Steam, and composes them into a
runnable server. I wrote it so that nobody else has to undergo the
same terrifying manual procedure I did which involved waiting for days
to finish uploading the enormous game files to a VPS off a slow home
DSL line.

Here is what it does exactly:

* Downloads the game data files from Steam
* Downloads the current server binary from BIS website
* Downloads the necessary PBOs
* Downloads the Linux hive port by denisio
* Composes all of the above to create a working server environment
* Creates a single, default database instance and fills it with the default dump

On a DigitalOcean VPS, the whole process takes 10 minutes.
What do I need?
---------------

* A Linux machine with a recent (2.16+) glibc, Debian Wheezy works
* About 20Gb disk space and 2Gb RAM (the server will probably run with less; haven't tried)
* A Steam account with Arma II and Arma II: AO

How do I run this?
------------------

* If possible, create a separate system user, e.g. `epoch`, and perform all operations in and as it
* Clone this repository with `git clone git@github.com:emestee/dayz-epoch-linux-server-magic.git`
* On Debian, run `packages.sh` **as root** to install the prerequisites. Otherwise look at the content of the file
  and install the equivalent packages.
* Copy the `CONFIGURATION-dist` file to `CONFIGURATION` and edit it. At the bare minimum insert your steam login and password.
  If you have Steam Guard enabled, at the download stage it will ask you for a guard code that you receive via the email
  associated with your account.  **Important**: after the installation is finished, remove your login/password from this file.
  Never leave it on a server.
* Run `./install.sh all`

Occasionally Steam would barf and the download will stop. Just try again.

After the whole thing finished running, hopefully without failure, you
will end up with a preconfigured server in `../epoch`.

It failed, what do I do?
------------------------

It's probably my fault! This script is a hack. My goal is to make the
procedure painless. Let me know and I will try to help you fixing it.

If something was wrong with your configuration, adjust it and perform
`./install.sh reset` and then `./install.sh all` again.

Try to figure out what went wrong. The script is organized into
stages; reset as above, look at the `all` procedure, and execute every stage manually
via `./install.sh <stage>`.

What's next?
------------

* Check the game server will run correctly by going to the server directory and running `./epoch.sh`
* Log in to the game as a player, run around, kill some zombies, log off, log on again and see that everything is fine (you're 
  spawned back where you were and your stuff isn't missing)
* Configure your server (hostname, motd, slots, password, etc). Note that the current server PBO has missions in Russian
  because that's how denisio publishes it. The recipe how to fix it can be found on epochmod.com forums.
* Run with `./restarter.pl`
* After everything is in order, delete this installer, or at the very least, **remove your steam user and password from the `CONFIGURATION` file**

Thanks
------

* BIS for an amazing game and the engine
* Epoch mod developers 
* denisio for porting the hive mechanism to Linux
* DeanReid for help
