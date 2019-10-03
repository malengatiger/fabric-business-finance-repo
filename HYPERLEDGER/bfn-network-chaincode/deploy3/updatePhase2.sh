#!/bin/bash

export NODE_CONFIG=$(cat cardstore-cloudant.json)

echo ============ check, stop and start bfnrestv3 ============
cf app bfnrestv3
cf stop bfnrestv3
echo =========== start composer REST server: bfnrestv3
cf start bfnrestv3
echo
echo
echo ======== ping BFN .............. =================
echo
composer network ping --card admin@bfn
echo ==================================================
echo == Check that bfnrestv3 has started successfully
echo == If it has, BFN is in bizness!!
echo ==================================================