"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const fabric_network_1 = require("fabric-network");
const z = '\n\n';
class TestConnection {
    static testConnection(wallet, profile) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            // Create a new gateway for connecting to our peer node.
            console.log(`${z}${z}💦  💦  💦  TestConnection creating new Gateway ...${z}`);
            const gateway = new fabric_network_1.Gateway();
            const options = {
                wallet: wallet,
                identity: "org1admin",
                discovery: {
                    enabled: true
                }
            };
            console.log(`${z}💦  💦  💦 bconnecting to Gateway:  ${z}${JSON.stringify(profile)}${z} `);
            yield gateway.connect(profile, options);
            // Get the CA client object from the gateway for interacting with the CA.
            const ca2 = gateway.getClient().getCertificateAuthority();
            console.log(ca2.toString());
            const peer = gateway
                .getClient()
                .getPeer("6a8196c6cae84bbaa5b4606fbaba63a8-peer8193a3.bfncluster.us-south.containers.appdomain.cloud:7051");
            console.log(`${z} 💦  💦  💦  Peer Name: ${peer.getName()} Peer Url: ${peer.getUrl()}`);
            console.log(`${z} Gateway Options: ${JSON.stringify(gateway.getOptions())}`);
            const adminIdentity = gateway.getCurrentIdentity();
            console.log(`${z}  💦  💦  💦  adminIdentity:  ${adminIdentity} ${z}`);
            try {
                // ################ Error occurs here ########################
                const network = yield gateway.getNetwork("channel1");
                // ############################################################
                const channel = network.getChannel();
                const contract = network.getContract("bfn-chaincode1");
                console.log(`${z}   💦  💦  💦  channel: ${z}`);
                console.log(channel);
                const peers = channel.getPeers();
                peers.forEach(peer => {
                    console.log(`${z}  💦  💦  💦  peer: ${peer.getName}`);
                });
                console.log(`${z}  💦  💦  💦  contract: ${z}`);
                console.log(contract);
                console.log(`${z} 💓 💓 💓 💓 💓 💓 💓 💓 💓  - We seem to be connected! YEBO!!!!`);
            }
            catch (e) {
                console.error(`${z} Failed to connect to network : ${e}`);
                throw e;
            }
        });
    }
}
exports.TestConnection = TestConnection;
//# sourceMappingURL=errors.js.map