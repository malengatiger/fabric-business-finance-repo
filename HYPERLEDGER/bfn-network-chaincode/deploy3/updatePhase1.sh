#!/bin/bash
echo ==================== Installing new version of BFN bna file ...
export NODE_CONFIG=$(cat cardstore-cloudant.json)
composer network install -c adminCard -a bfn@0.0.25.bna
echo ======================================================================
echo == Go to IBM console and navigate to Install Code. 
echo == From the little dot menu, update the network
echo == to the new version.
echo ==
echo == Come back to this terminal and, if necessary ..., usually necessary
echo == Run ./updatePhase2.sh
echo =======================================================================