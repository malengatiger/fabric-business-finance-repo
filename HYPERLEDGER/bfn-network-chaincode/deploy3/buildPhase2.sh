#!/bin/bash
echo
echo
echo ===========================================================================
echo Starting Blockchain Build Phase 2
echo Installing and starting the business network
echo note: the whole thing takes a few minutes to execute
echo ===========================================================================
echo
echo
cd /Users/mac/Documents/GitHub/business-finance-network/deploy3

echo setting up cloudant environment parameters ...
export NODE_CONFIG=$(cat cardstore-cloudant.json)

echo installing the FBN bna file on the network ....
composer network install -c adminCard -a bfn@0.0.1.bna

echo starting the network ..... will be maybe a few minutes ...
composer network start -c adminCard -n bfn -V 0.0.1 -A admin -C ./credentials/admin-pub.pem -f delete_me.card
rm delete_me.card

echo creating and importing the admin@bnf card to Cloudant......
composer card create -n bfn -p ./connection-profile.json  -u admin -c ./credentials/admin-pub.pem -k ./credentials/admin-priv.pem
composer card import -f admin@bfn.card

echo pinging the BFN network ....
composer network ping --card admin@bfn

echo If this is a brand new setup, push the malengatiger/bfn-composer-rest-server to IBM platform
echo see commands txt in this here directory
echo stop the currently running bfnrestv3 container ...
cf stop bfnrestv3
echo start the Fresh Prince of Bel Air - this takes a minute or three ....
cf start bfnrestv3

echo ===========================================================================
echo ===== BuildPhase 2 is complete - the BFN network is ready to provide services
echo ===== Enjoy the BFN Blockchain!!
echo ===========================================================================
echo
echo