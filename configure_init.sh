#!/usr/bin/env bash

# i just need to set the main init script to start on runlevels 3 4 5 and stop on runlevels 0 and 6
ln -sf /etc/init.d/lfs /etc/rc.d/rc3.d/S80lfs
ln -sf /etc/init.d/lfs /etc/rc.d/rc4.d/S80lfs
ln -sf /etc/init.d/lfs /etc/rc.d/rc5.d/S80lfs
ln -sf /etc/init.d/lfs /etc/rc.d/rc0.d/K01lfs
ln -sf /etc/init.d/lfs /etc/rc.d/rc6.d/K01lfs
