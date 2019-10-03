"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const fabric_network_1 = require("fabric-network");
const cloudant_service_1 = require("./cloudant-service");
const constants_1 = require("../models/constants");
const z = '\n\n';
/*

*/
class ConnectToChaincode {
    static getContract(userName, wallet) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const start1 = new Date().getTime();
            const profile = yield cloudant_service_1.CloudantService.getConnectionProfile();
            const gateway = new fabric_network_1.Gateway();
            const options = {
                wallet: wallet,
                identity: userName,
                discovery: {
                    enabled: true,
                    asLocalhost: false
                }
            };
            const start2 = new Date().getTime();
            const elapsed1 = (start2 - start1) / 1000;
            yield gateway.connect(profile, options);
            const start3 = new Date().getTime();
            try {
                const network = yield gateway.getNetwork(constants_1.Constants.DEFAULT_CHANNEL);
                const contract = network.getContract(constants_1.Constants.DEFAULT_CHAINCODE);
                const start4 = new Date().getTime();
                const elapsed4 = (start4 - start3) / 1000;
                console.log(`⌛️ ⌛️ ⌛️ --> Contract object instantiation took 💦 ${elapsed4} seconds `);
                return contract;
            }
            catch (e) {
                console.error(`${z} Failed to obtain Contract object : ${e}`);
                throw e;
            }
        });
    }
}
exports.ConnectToChaincode = ConnectToChaincode;
//# sourceMappingURL=connection.js.map