"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const fs = tslib_1.__importStar(require("fs"));
const os = tslib_1.__importStar(require("os"));
const path = tslib_1.__importStar(require("path"));
const fabric_network_1 = require("fabric-network");
const cloudant_service_1 = require("./cloudant-service");
const z = "\n";
class WalletHelper {
    static writeFile(contents, filePath) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`☕️ ☕️ ☕️ write file ${filePath} ...`);
            try {
                fs.writeFile(filePath, contents, err => {
                    if (err) {
                        console.log(`File write failed ${err}`);
                        throw new Error(`Failed to write file ${err}`);
                    }
                    console.log(`💙 💕💕💕 file written successfully: ${filePath}`);
                    return null;
                });
            }
            catch (e) {
                console.log(`File write failed ${e}`);
                throw new Error(`Failed to write file ${e}`);
            }
        });
    }
    static getTemporayDirectory() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            // console.log(`☕️ ☕️ Getting temporary directory`);
            let temporaryDirectory;
            try {
                temporaryDirectory = fs.mkdtempSync(path.join(os.tmpdir(), "wallet" + new Date().getTime()));
                fs.chmod(temporaryDirectory, "755", function (err) {
                    if (err) {
                        throw new Error(`👿 👿 👿 Problem with temp dir ${err}`);
                    }
                    else {
                        // console.log(
                        //   `🔵 🔵 temporary directory ready to rumble: ${temporaryDirectory}`
                        // );
                        return temporaryDirectory;
                    }
                });
            }
            catch (e) {
                console.log(`👿 👿 👿 Problem getting directory ${e}`);
                throw e;
            }
            return temporaryDirectory;
        });
    }
    static getAdminWallet() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const ADMIN_USER = "org1admin";
            const dir = yield this.getTemporayDirectory();
            let wallet = new fabric_network_1.FileSystemWallet(dir);
            let mspId;
            let certif;
            let privateKey;
            const start1 = new Date().getTime();
            const obj = yield cloudant_service_1.CloudantService.getWalletCache(ADMIN_USER);
            const start2 = new Date().getTime();
            const elapsed1 = (start2 - start1) / 1000;
            let cache;
            if (obj.cache) {
                cache = obj.cache;
                const userContentJson = JSON.parse(cache.userContent);
                mspId = userContentJson.mspid;
                certif = userContentJson.enrollment.identity.certificate;
                privateKey = cache.privateKey;
                const identity = fabric_network_1.X509WalletMixin.createIdentity(mspId, certif, privateKey);
                const start3 = new Date().getTime();
                wallet = new fabric_network_1.FileSystemWallet(dir);
                yield wallet.import(ADMIN_USER, identity);
                const start4 = new Date().getTime();
                const exists = yield wallet.exists(ADMIN_USER);
                if (exists) {
                    // console.log(
                    //   `${z}${z}💓 💓 💓 💓 recovered admin wallet exists! 🤖 🤖 🤖 🤖 we should have a fucking 💚 party!\n\n`
                    // );
                }
                else {
                    const msg = `${z}${z}👿 👿 👿 👿 👿 👿 FAILED. 😡 admin wallet no mas, Senor!`;
                    console.error(msg);
                    throw new Error(msg);
                }
            }
            const start6 = new Date().getTime();
            const elapsed3 = (start6 - start1) / 1000;
            console.log(`⌛️ ⌛️ ⌛️   wallet recovery took ${elapsed3} seconds`);
            return wallet;
        });
    }
    static getFileSystemWallet(userName) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            let imWallet;
            let mspId;
            let certif;
            let privateKey;
            const obj = yield cloudant_service_1.CloudantService.getWalletCache(userName);
            let cache;
            if (obj.cache) {
                cache = obj.cache;
                const userContentJson = JSON.parse(cache.userContent);
                mspId = userContentJson.mspid;
                certif = userContentJson.enrollment.identity.certificate;
                privateKey = cache.privateKey;
                const identity = fabric_network_1.X509WalletMixin.createIdentity(mspId, certif, privateKey);
                const walletPath = path.join(process.cwd(), `wallet${userName}${new Date().getTime()}`);
                const dir = fs.mkdtempSync(walletPath);
                imWallet = new fabric_network_1.FileSystemWallet(dir);
                // console.log(`${z} 💦 💦 💦  Importing wallet ... `);
                yield imWallet.import(userName, identity);
                const exists = yield imWallet.exists(userName);
                if (!exists) {
                    const msg = `${z}👿  👿  👿 An identity for the user ${userName} does not exist in the wallet${z}`;
                    console.error(msg);
                    throw new Error(msg);
                }
                console.log(`💕 💕  💕 💕  💕 💕  💕 💕   user wallet is CREATED OK ....`);
                return imWallet;
            }
            else {
                throw new Error(`👿  👿  👿  User wallet recovery failed`);
            }
        });
    }
}
exports.WalletHelper = WalletHelper;
//# sourceMappingURL=wallet-helper.js.map