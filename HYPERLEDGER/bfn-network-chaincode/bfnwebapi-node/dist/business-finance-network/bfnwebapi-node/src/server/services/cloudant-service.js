"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
// import lodash from "lodash";
const wallet_cache_1 = require("../models/wallet-cache");
const Cloudant = require("@cloudant/cloudant");
require("dotenv").load();
const account = process.env.CLOUDANT_USERNAME || "";
const key = process.env.CLOUDANT_API_KEY || "";
const password = process.env.CLOUDANT_API_PASSWORD || "";
const cloudantUrl = process.env.CLOUDANT_URL || "";
const DATABASE = "bfnwallets";
let db;
const zz = "\n";
/*

*/
class CloudantService {
    constructor() { }
    // NEEDS _admin permission
    static createDatabase(dbName) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                this.cloudant.db.create(dbName, (err, body, header) => {
                    if (err) {
                        console.error(err);
                        reject(null);
                        return;
                    }
                    console.log("Create Database");
                    console.log(body);
                    resolve(body);
                });
            });
        });
    }
    // NEEDS _admin permission
    static dropDatabase(dbName) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                this.cloudant.db.destroy(dbName, (err, body, header) => {
                    if (err) {
                        console.error(err);
                        reject(null);
                        return;
                    }
                    console.log("Destroy Database");
                    console.log(body);
                    resolve(body);
                });
            });
        });
    }
    static use() {
        //console.log(`\n\n😡  😡 😡  😡  --->  account: ${account} apiKey: ${key} pswd: ${password} 😡  😡 😡  😡`)
        try {
            if (!this.cloudant) {
                //this.cloudant = Cloudant({ account, key, password });
                console.log(`😡 😡 😡 😡   **** using url to connect to cloudant:  💦 💦 ${cloudantUrl} ......`);
                this.cloudant = Cloudant({ url: cloudantUrl });
                console.log(`cloudant accessed OK 💦 💦 ${this.cloudant}`);
            }
            db = this.cloudant.db.use(DATABASE);
        }
        catch (e) {
            console.error(`${zz}👿 👿 👿 👿 cloudant fucked: ${e}${zz}`);
        }
        return db;
    }
    static getDatabaseCreds() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const db = this.use();
                if (!db) {
                    console.error(`👿 👿 👿 👿 cloudant db not. good. bad. terrible. `);
                }
                else {
                    console.log(`${zz}💕 💕  - db seems OK 💕 💕 ${db} ${zz}`);
                }
            }
            catch (e) {
                console.error(`${zz}👿 👿 👿 👿 db failed: 👿 👿 👿 👿\n ${e} ${zz}`);
            }
            return {
                apiKey: key,
                account: account,
                password: password
            };
        });
    }
    static getConnectionProfile() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            db = this.use();
            console.log(`😡 😡 😡 😡  ----   getting ConnectionProfile ... from cloudant: 💦 ${db} ---- 😡 😡 😡 😡`);
            return new Promise((resolve, reject) => {
                db.get("connectionProfile", (err, data, headers) => {
                    if (err) {
                        console.error(`\n\n👿 👿 👿 connectionProfile error: ${err}`);
                        reject(null);
                        return;
                    }
                    else {
                        console.log(`❤️  ❤️  ❤️ - we seem to be kool here: ${data}`);
                        console.log(data);
                        console.log('🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 ');
                        console.log(data.certificateAuthorities);
                    }
                    const mData = data;
                    resolve(mData);
                });
            });
        });
    }
    static getConfig() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            db = this.use();
            console.log(`${zz}😡 😡  ----   getConfig ...${zz}`);
            return new Promise((resolve, reject) => {
                const db = this.use();
                db.get("config", (err, data, headers) => {
                    if (err) {
                        console.error(err);
                        reject(null);
                        return;
                    }
                    console.log(`${zz}💙  💚  data returned for config call:${zz} ${JSON.stringify(data)} ${zz}`);
                    const mData = data.json;
                    resolve(mData);
                });
            });
        });
    }
    static insertWalletCache(walletCache) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            // console.log(`\n🙄 🙄 🙄 getting existing wallet, if any`);
            db = this.use();
            try {
                const cache = yield this.getWalletCache(walletCache._id);
                if (cache.data !== null) {
                    // console.log(
                    //   `${zz}💕 💕   returned cache ${cache.data._id} rev: ${cache.data._rev} will do delete now`
                    // );
                    yield this.deleteWalletCache(cache.data._id, cache.data._rev);
                }
                // console.log(
                //   `${zz}🔵 🔵 🔵 🔵   we do not have a cache! -- INSERT it NOW`
                // );
                try {
                    db.insert({
                        _id: walletCache._id,
                        data: walletCache.toJson()
                    });
                    console.log(`${zz}💙  💚  💛 💙  💚  💛  -- wallet written to cloudant ....${zz}`);
                }
                catch (e) {
                    console.error(`${zz}\n😡 😡 😡 😡 😡 😡  ---- @@@@@@@@@@ error here, unable to insert: ${zz}${e}`);
                }
            }
            catch (e) {
                console.log(`${zz}\n 😡 😡 😡 😡 😡 😡  .....  Fell down here .....${zz}`);
                console.error(e);
                throw e;
            }
        });
    }
    static getWalletCache(_id) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            let cache;
            db = this.use();
            // console.log(`${zz}😡 😡  ----   getWalletCache ...${zz}`);
            return new Promise((resolve, reject) => {
                db.get(_id, (err, data, headers) => {
                    if (err) {
                        console.error(err);
                        resolve({
                            data: null
                        });
                        return;
                    }
                    // console.log(
                    //   `${zz}💙  💚  💛 💙  💚  💛  data returned for get call:${zz} ${JSON.stringify(
                    //     data
                    //   )} ${zz}`
                    // );
                    const mData = data.data;
                    cache = new wallet_cache_1.WalletCache();
                    cache.fromJson(mData);
                    resolve({
                        cache: cache,
                        data: data
                    });
                });
            });
        });
    }
    static deleteWalletCache(_id, _rev) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                const db = this.use();
                db.destroy(_id, _rev, (err, body, header) => {
                    if (err) {
                        console.error(err);
                        reject(() => {
                            const msg = `Database delete failed - ${err}`;
                            console.log(msg);
                            throw new Error(msg);
                        });
                        return;
                    }
                    console.log(`Document deleted`);
                    console.log(`body returned: ${body}`);
                    resolve(body);
                });
            });
        });
    }
    static searchDocument(designName, indexName, searchText) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                const db = this.use();
                db.search(designName, indexName, { q: searchText }, (err, result, header) => {
                    if (err) {
                        console.error(err);
                        reject(null);
                        return;
                    }
                    console.log("Search Document");
                    console.log(result);
                    resolve(result);
                });
            });
        });
    }
}
exports.CloudantService = CloudantService;
//# sourceMappingURL=cloudant-service.js.map