"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const cloudant_service_1 = require("./cloudant-service");
const path = tslib_1.__importStar(require("path"));
const fs = tslib_1.__importStar(require("fs"));
const fabric_network_1 = require("fabric-network");
const wallet_helper_1 = require("./wallet-helper");
const wallet_cache_1 = require("../models/wallet-cache");
const z = "\n";
class UserService {
    static enroll(userName) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`${z}💦  💦  💦 start enrolling user ${userName} ...`);
            let adminWallet;
            let userWallet;
            const config = yield cloudant_service_1.CloudantService.getConfig();
            const profile = yield cloudant_service_1.CloudantService.getConnectionProfile();
            try {
                adminWallet = yield wallet_helper_1.WalletHelper.getAdminWallet();
                console.log(`${z}💦  💦  💦  UserService: we have recovered admin wallet ${z}`);
            }
            catch (e) {
                throw e;
            }
            try {
                userWallet = yield wallet_helper_1.WalletHelper.getFileSystemWallet(userName);
                throw new Error(`${userName} - wallet already exists`);
            }
            catch (e) {
                //todo - create user wallet
                console.log(`${z}${z}💦  💦  💦  creating user wallet for ${userName}...`);
            }
            // Create a new gateway for connecting to our peer node.
            console.log(`${z}${z}💦  💦  💦  creating new Gateway ...${z}`);
            const gateway = new fabric_network_1.Gateway();
            const options = {
                wallet: adminWallet,
                identity: "admin",
                discovery: {
                    asLocalhost: false,
                    enabled: true
                }
            };
            console.log(`${z}💦  💦  💦  connecting to Gateway ... using: ${z} ${JSON.stringify(profile)} ${z}`);
            yield gateway.connect(profile, options);
            // Get the CA client object from the gateway for interacting with the CA.
            const ca = gateway.getClient().getCertificateAuthority();
            const adminIdentity = gateway.getCurrentIdentity();
            console.log(`${z}${z}👮  👮  👮 Certificate Authority from Gateway: ${z} ${ca.toString()} ${z}`);
            console.log(`${z}${z}💦  💦  💦  Register the user, enroll the user, and import the new identity into the wallet.`);
            const secret = yield ca.register({
                affiliation: "org1",
                enrollmentID: userName,
                role: "client"
            }, adminIdentity);
            console.log(`${z}😎 😎 😎  Enrolment secret: ${secret}  😎 😎 😎 ${z}`);
            const enrollment = yield ca.enroll({
                enrollmentID: userName,
                enrollmentSecret: secret
            });
            console.log(`${z}💦  💦  💦  create new user identity ...${z} enrolmentKey: ${enrollment.key} ${z} ${z} enrollment.certificate: ${z}${enrollment.certificate} ${z} enrollment.rootCertificate: ${z}${enrollment.rootCertificate}`);
            const userIdentity = fabric_network_1.X509WalletMixin.createIdentity(config.orgMSPID, enrollment.certificate, enrollment.key.toBytes());
            console.log(`${z}${z}💦  💦  💦  immport into user wallet ${userName}... ${userIdentity.type}`);
            const mpath = path.join(process.cwd(), `wallet${userName}`);
            const uDir = fs.mkdtempSync(mpath);
            userWallet = new fabric_network_1.FileSystemWallet(uDir);
            userWallet.import(userName, userIdentity);
            const gt = new fabric_network_1.Gateway();
            const opts = {
                identity: userName,
                wallet: userWallet,
                discovery: { "enabled": true, "asLocalhost": false }
            };
            gt.connect(profile, opts);
            const net = yield gt.getNetwork('channel1');
            const channel = net.getChannel();
            console.log(`channel: ${channel}`);
            const exists = yield userWallet.exists(userName);
            if (exists) {
                console.log(`${z}💛 💛 💛 💛 💛 💛 💛  user exists in wallet !!!`);
            }
            else {
                console.log(`${z} 👿 👿  👿 👿  👿 👿  👿 👿 user DOES NOT exist in wallet !!!`);
                throw new Error(`${z} 👿 👿  👿 👿  👿 👿  👿 👿 user DOES NOT exist in wallet !!!`);
            }
            console.log(`${z}💦  💦  💦  upload user wallet to cloudant ... ${uDir}. Files in uDir:`);
            let dirPath = '';
            fs.readdirSync(uDir).forEach(file => {
                console.log(`${z}🔵  🔵  🔵  🔵   File in user wallet: 💕 💕 💕  :: ${file}${z}`);
                const isDirectory = fs
                    .lstatSync(uDir + "/" + file)
                    .isDirectory();
                if (isDirectory) {
                    console.log(` 💛  file IS a directory`);
                    dirPath = uDir + "/" + file;
                }
                else {
                    console.log(`😡   file is NOT a directory`);
                    const str = fs.readFileSync(uDir + "/" + file);
                    console.log(`${str}${z}`);
                }
            });
            fs.readdirSync(dirPath).forEach(file => {
                console.log(`${z}############  💛   💛  File produced by import call: ${file}`);
            });
            yield this.uploadWallet(dirPath, userName, secret);
            const msg = `${z}💙  💚  💛  Successfully registered and enrolled user ${userName} and imported it into the wallet`;
            console.log(msg);
            return msg;
        });
    }
    static uploadWallet(temporaryWalletDirectory, userName, secret) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`${z}🔵  🔵  🔵  🔵   uploading ${temporaryWalletDirectory} wallet directory files to cloudant ... 🔵  🔵`);
            fs.readdir(temporaryWalletDirectory, function (err, files) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    if (err) {
                        console.error(`${z}👿 👿  Could not list the directory. 👿 Fuck it!`, err);
                        throw new Error(" 👿 👿  Failed to list temporary directory files containing identity");
                    }
                    else {
                        const directoryFromCA = temporaryWalletDirectory + "/" + files[0];
                        let isDirectory = false;
                        try {
                            isDirectory = fs.lstatSync(directoryFromCA).isDirectory();
                        }
                        catch (e) {
                            throw new Error(" 👿 👿  Failed to check temporary directory files containing identity");
                        }
                        if (isDirectory) {
                            return yield UserService.uploadFiles(directoryFromCA, userName, secret);
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
    static uploadFiles(directoryFromCA, userName, secret) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            let cnt = 0;
            let userContent, privateContent, publicContent;
            fs.readdir(directoryFromCA, function (error, fileList) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.log(`${z}🔵  🔵 CA directory has: ` +
                        fileList.length +
                        " files. Should be 3 💕 💕 💕 of them!");
                    if (fileList.length < 3) {
                        const msg = `😡  😡  -- User director has only ${fileList.length}`;
                        console.log(msg);
                        throw new Error(msg);
                    }
                    if (!error) {
                        for (const file of fileList) {
                            const mpath = directoryFromCA + "/" + file;
                            console.log(`${z}😡 😡 - reading ${file} for saving in cloudant ... 😡 😡 `);
                            const buffer = fs.readFileSync(mpath);
                            const fileContents = buffer.toString("utf8");
                            const privateKey = fileContents.search("PRIVATE");
                            const publicKey = fileContents.search("PUBLIC");
                            if (privateKey > -1) {
                                privateContent = fileContents;
                            }
                            else {
                                if (publicKey > -1) {
                                    publicContent = fileContents;
                                }
                                else {
                                    userContent = fileContents;
                                }
                            }
                            cnt++;
                        }
                        console.log(`${z}🔵  🔵 🔵  🔵 creating walletCache for cloudant ...`);
                        const cache = new wallet_cache_1.WalletCache();
                        cache._id = userName;
                        cache.userContent = userContent;
                        cache.privateKey = privateContent;
                        cache.publicKey = publicContent;
                        cache.secret = secret;
                        cache.date = new Date().toISOString();
                        yield cloudant_service_1.CloudantService.insertWalletCache(cache);
                        const msg = `${z}❤️ ❤️ ❤️   Blockchain User ${userName} enrolled, wallet identity files uploaded and cached: 💕💕  ${cnt}   💕💕`;
                        console.log(msg);
                        return msg;
                    }
                    else {
                        const msg = `${z}👿👿👿 Error saving wallet 👿👿👿${z}`;
                        console.log(msg);
                        throw new Error(msg);
                    }
                });
            });
        });
    }
}
exports.UserService = UserService;
//# sourceMappingURL=user-service.js.map