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
const transaction_service_1 = require("./transaction-service");
const constants_1 = require("../models/constants");
//
// expected parameters received in json data structure
let organization = "org1msp";
let caURL = "https://6a8196c6cae84bbaa5b4606fbaba63a8-ca8f5ceb.bfncluster.us-south.containers.appdomain.cloud:7054"; //certificate authority url - from blockchain connection profile json file
let enrollSecret = "adminpw";
let temporaryWalletDirectory = "";
//curl --header "Content-Type: application/json"   --request POST   --data '{"debug": "true"}'   https://us-central1-business-finance-dev.cloudfunctions.net/registerAdmin
const z = "\n";
let mUser;
/*
Register user and save creds in Cloudant database
*/
class UserRegistrationSevice {
    static enrollUser(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`${z}🔵 🔵 🔵 🔵  REGISTER BFN USER ${jsonString}  starting .... 🔵 🔵 🔵 🔵${z}`);
            //
            mUser = JSON.parse(jsonString);
            const config = yield cloudant_service_1.CloudantService.getConfig();
            organization = config.orgMSPID;
            console.log(`${z} ${z} 💚 💚   organization from config : ${organization}`);
            //
            const m = yield cloudant_service_1.CloudantService.getConnectionProfile();
            const keysArray = Object.keys(m.certificateAuthorities);
            let mValue;
            for (var i = 0; i < keysArray.length; i++) {
                var key = keysArray[i];
                mValue = m.certificateAuthorities[key];
            }
            if (mValue) {
                caURL = mValue.url;
                console.log(`${z}🤢 🤢   certificateAuthority url from cloudant:  ${z}${z}${mValue.url}`);
            }
            else {
                console.log(`${z}🔵 🔵 default certificateAuthority url: ${z}${z}${caURL}`);
            }
            // const buff = Buffer.from(betaCert64, "base64");
            // const betaCert = buff.toString("ascii");
            // const buff2 = Buffer.from(betaKey64, "base64");
            // const betaKey = buff2.toString("ascii");
            try {
                temporaryWalletDirectory = yield wallet_helper_1.WalletHelper.getTemporayDirectory();
                const ca = new fabric_ca_client_1.default(caURL);
                const wallet = new fabric_network_1.FileSystemWallet(temporaryWalletDirectory);
                //Enroll the user, and import the new identity into the wallet.
                console.log(`${z}🔵 🔵  enrolling ${jsonString} ...................`);
                const enrollment = yield ca.enroll({
                    enrollmentID: mUser.userName,
                    enrollmentSecret: mUser.secret
                });
                console.log(`${z}${z}💚 💚 💚  ${mUser.userName} enrolled on certificate authority - enrollment.key:  ${enrollment.key.toBytes()}   💚 💚 💚 `);
                const identity = fabric_network_1.X509WalletMixin.createIdentity(organization, enrollment.certificate, enrollment.key.toBytes());
                yield wallet.import(mUser.userName, identity);
                console.log(`${z}✅ 💛 💛  Successfully enrolled user: 💚 ${mUser.userName}  ${identity.type}  
        💚 imported certs into wallet 💛 💛 💛`);
                return yield this.uploadWallet(mUser.userName);
            }
            catch (error) {
                const msg = ` 👿  👿  👿   Failed to enroll user ${mUser}: ${error}  👿  👿`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static uploadWallet(userName) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`${z}🔵  🔵  uploading ${temporaryWalletDirectory} wallet directory files to cloudant ... 🔵  🔵`);
            fs.readdir(temporaryWalletDirectory, function (err, files) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    if (err) {
                        console.error(`${z}👿 👿  Could not list the directory.`, err);
                        throw new Error(" 👿 👿  Failed to list temporary directory files containg identity");
                    }
                    else {
                        const directoryFromCA = temporaryWalletDirectory + "/" + files[0];
                        let isDirectory = false;
                        try {
                            isDirectory = fs.lstatSync(directoryFromCA).isDirectory();
                        }
                        catch (e) {
                            throw new Error(" 👿 👿  Failed to check temporary directory files containg identity");
                        }
                        if (isDirectory) {
                            return yield UserRegistrationSevice.uploadFiles(userName, directoryFromCA);
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
    static uploadFiles(userName, directoryFromCA) {
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
                        cache._id = userName;
                        cache.date = new Date().toISOString();
                        yield cloudant_service_1.CloudantService.insertWalletCache(cache);
                        const msg = `${z}🔵 🔵 🔵 🔵  Blockchain User enrolled, wallet identity files uploaded and cached: 💕💕  ${cnt}   💕💕`;
                        const user = yield transaction_service_1.TransactionService.send(constants_1.Constants.DEFAULT_USERNAME, constants_1.Constants.CHAIN_ADD_USER, mUser);
                        console.log(`user processed: ${user}`);
                        console.log(msg);
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
exports.UserRegistrationSevice = UserRegistrationSevice;
//# sourceMappingURL=user-registration-service.js.map