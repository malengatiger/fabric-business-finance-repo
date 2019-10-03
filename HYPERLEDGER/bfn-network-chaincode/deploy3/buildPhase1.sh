#!/bin/bash
echo
echo
echo ===========================================================================
echo Starting Blockchain Build Phase 1
echo Creating network cards and requesting cert from Fabric
echo Importing these cards into Cloudant database
echo ===========================================================================
echo 
echo IMPORTANT: Run this only after setting up the network on the IBM console
echo and downloading the connection settings. Assumes that the Cloudant database has been set up
echo
cd /Users/mac/Documents/GitHub/business-finance-network/deploy3

echo setting up cloudant environment parameters ...
export NODE_CONFIG=$(cat cardstore-cloudant.json)

echo create and import ca card with enrolSecret from Blockchain Platform ...
composer card create -f ca.card -p connection-profile.json -u admin -s 1317b81f53
composer card import -f ca.card -c ca
composer identity request --card ca --path ./credentials

echo create and import adminCard
composer card create -f adminCard.card -p connection-profile.json -u admin -c ./credentials/admin-pub.pem -k ./credentials/admin-priv.pem --role PeerAdmin --role ChannelAdmin
composer card import -f adminCard.card -c adminCard

echo ===========================================================================
echo ===== Phase 1 complete
echo
echo ===== IMPORTANT - IMPORTANT - IMPORTANT - IMPORTANT - IMPORTANT !!! Obey!!
echo ===== go to ibm cloud console and add cert from local file admin-pub.pem in the credentials folder
echo ===== sync cert from menu and restart peers
echo ===== navigate to channels and sync cert
echo =====
echo ===== when finished, run ./buildPhase2.sh
echo ===========================================================================
echo
echo