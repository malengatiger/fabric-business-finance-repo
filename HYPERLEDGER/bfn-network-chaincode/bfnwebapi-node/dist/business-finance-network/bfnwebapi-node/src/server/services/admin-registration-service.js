"use strict";
// ###################################################################################
// Request Certificates from CA and Register admin user, save wallet in cloud storage
// ###################################################################################
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const fs = tslib_1.__importStar(require("fs"));
const fabric_ca_client_1 = tslib_1.__importDefault(require("fabric-ca-client"));
const fabric_network_1 = require("fabric-network");
const wallet_helper_1 = require("./wallet-helper");
const cloudant_service_1 = require("./cloudant-service");
const wallet_cache_1 = require("../models/wallet-cache");
const connection_1 = require("./connection");
//
const adminUser = "org1admin";
let organization = "org1msp";
let caURL;
let enrollSecret = "org1adminpw";
let temporaryWalletDirectory = "";
//curl --header "Content-Type: application/json"   --request POST   --data '{"debug": "true"}'   https://us-central1-business-finance-dev.cloudfunctions.net/registerAdmin
//let userName: string;
const z = "\n";
/*
Register admin user and save creds in Cloudant database
*/
class AdminRegistrationSevice {
    static enrollAdmin() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`🔵 🔵 🔵 🔵  REGISTER BFN ADMIN USER starting .... 🔵 🔵 🔵 🔵`);
            const profile = yield cloudant_service_1.CloudantService.getConnectionProfile();
            if (!profile) {
                const msg = '😡 😡 Unable to get connection profile from 💦 💦 Cloudant';
                console.error(msg);
                throw new Error(msg);
            }
            console.log(profile);
            const keysArray = Object.keys(profile.certificateAuthorities);
            let mValue;
            for (var i = 0; i < keysArray.length; i++) {
                var key = keysArray[i];
                mValue = profile.certificateAuthorities[key];
            }
            organization = profile.client.organization;
            console.log(`💚 💚   organization from profile : 🎁 ${organization}`);
            if (mValue) {
                caURL = mValue.url;
                console.log(`🤢 🤢   certificateAuthority url from cloudant:  🔑 🔑 🔑 ${mValue.url}`);
            }
            else {
                console.log(`🔵 🔵 default certificateAuthority url: ${caURL}`);
            }
            try {
                temporaryWalletDirectory = yield wallet_helper_1.WalletHelper.getTemporayDirectory();
                const ca = new fabric_ca_client_1.default(caURL);
                const wallet = new fabric_network_1.FileSystemWallet(temporaryWalletDirectory);
                //Enroll the admin user, and import the new identity into the wallet.
                console.log("🔵 🔵  enrolling ...................");
                const enrollment = yield ca.enroll({
                    enrollmentID: adminUser,
                    enrollmentSecret: enrollSecret
                });
                console.log(`💚 💚 💚  admin user enrolled on certificate authority - enrollment.key:  ${enrollment.key.toBytes()}   💚 💚 💚 `);
                const identity = fabric_network_1.X509WalletMixin.createIdentity(organization, enrollment.certificate, enrollment.key.toBytes());
                yield wallet.import(adminUser, identity);
                console.log(`${z}✅ 💛 💛  Successfully enrolled admin user: 💚 ${adminUser}  ${identity.type}  
        💚 imported certs into wallet 💛 💛 💛`);
                console.log(`${z}${z}💦  💦  💦  Upload wallet to Cloudant .... `);
                const msg = yield AdminRegistrationSevice.uploadWallet();
                return msg;
            }
            catch (error) {
                const msg = `👿👿👿 Failed to enroll admin user ${adminUser}: ${error}  👿👿`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static uploadWallet() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`🔵  🔵  uploading ${temporaryWalletDirectory} wallet directory files to Firesreto ... 🔵  🔵`);
            yield fs.readdir(temporaryWalletDirectory, function (err, files) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    if (err) {
                        console.error(`👿 👿  Could not list the directory.`, err);
                        throw new Error("👿 👿  Failed to list temporary directory files containg identity");
                    }
                    else {
                        const directoryFromCA = temporaryWalletDirectory + "/" + files[0];
                        let isDirectory = false;
                        try {
                            isDirectory = fs.lstatSync(directoryFromCA).isDirectory();
                        }
                        catch (e) {
                            throw new Error("👿👿  Failed to check temporary directory files containg identity");
                        }
                        if (isDirectory) {
                            return yield AdminRegistrationSevice.uploadFiles(directoryFromCA);
                        }
                        else {
                            console.log("⚠️ ⚠️ ⚠️  WTF, only one file created by CA, expected 3 inside directory");
                            throw new Error("⚠️  WTF, only one file created by CA, expected 3");
                        }
                    }
                });
            });
            return `💙  💚  💛  💙  💚  💛  we be pretty cool, Bro!`;
        });
    }
    static uploadFiles(directoryFromCA) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            let cnt = 0;
            const cache = new wallet_cache_1.WalletCache();
            fs.readdir(directoryFromCA, function (error, fileList) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.log(`${z}🔵  🔵 CA directory has: ` +
                        fileList.length +
                        " files. Should be 3 💕 💕 💕 of them!");
                    if (!error) {
                        for (const file of fileList) {
                            const mpath = directoryFromCA + "/" + file;
                            console.log(`${z}😡 😡 - reading file: ${file} for saving in cloudant ... 😡 😡 `);
                            const buffer = fs.readFileSync(mpath);
                            const fileContents = buffer.toString("utf8");
                            const privateKey = fileContents.search("PRIVATE");
                            const publicKey = fileContents.search("PUBLIC");
                            if (privateKey > -1) {
                                cache.privateKeyFileName = file;
                                cache.privateKey = fileContents;
                            }
                            else {
                                if (publicKey > -1) {
                                    cache.publicKey = fileContents;
                                    cache.publicKeyFileName = file;
                                }
                                else {
                                    cache.userContent = fileContents;
                                    cache.userFileName = file;
                                }
                            }
                            cnt++;
                        }
                        cache._id = adminUser;
                        cache.date = new Date().toISOString();
                        yield cloudant_service_1.CloudantService.insertWalletCache(cache);
                        const msg = `${z}🔵 🔵 🔵 🔵  Blockchain Admin User enrolled, wallet identity files uploaded and cached: 💕💕  ${cnt}   💕💕`;
                        console.log(msg);
                        // test wallet recovery from cloudant
                        console.log(`${z}🔵 🔵 🔵 🔵  ############ TESTING WALLET RECOVERY #################  🔵 🔵 🔵 🔵  ${z}`);
                        const recWallet = yield wallet_helper_1.WalletHelper.getFileSystemWallet(adminUser);
                        const contract = yield connection_1.ConnectToChaincode.getContract(adminUser, recWallet);
                        if (contract) {
                            console.log(`${z}❤️  ❤️  ❤️  Received contract object OK. Yes!! ❤️  ❤️  ❤️ ${z}`);
                            const tx = contract.createTransaction('init');
                            console.log(`${z}💦  💦  💦   transaction name: ${tx.getName()} txId: ${tx.getTransactionID().getTransactionID()}`);
                            const payload = yield tx.submit();
                            console.log(`${z}  ☕️  ☕️  ☕️  ☕️  tx.submit - Payload: ${z}${payload.toString()}`);
                            const payload2 = yield contract.submitTransaction('init');
                            console.log(`${z}  ☕️  ☕️  ☕️  ☕️  contract.submitTransaction - Payload: ${z}${payload2.toString()}`);
                        }
                        return msg;
                    }
                    else {
                        const msg = `${z}👿👿👿 Error reading wallet directory 👿👿👿${z}`;
                        console.log(msg);
                        throw new Error(msg);
                    }
                });
            });
        });
    }
}
exports.AdminRegistrationSevice = AdminRegistrationSevice;
//# sourceMappingURL=admin-registration-service.js.map