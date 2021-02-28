#!/bin/sh

echo "Starting ZeroTier"
zerotier-one -d # fork into background

echo "Starting BIRD"
/opt/bird/sbin/bird -f # run in foreground
