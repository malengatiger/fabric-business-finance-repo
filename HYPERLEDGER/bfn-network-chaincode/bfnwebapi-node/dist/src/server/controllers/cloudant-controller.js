"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const Cloudant = require("@cloudant/cloudant");
require("dotenv").load();
const account = process.env.CLOUDANT_USERNAME || "";
const key = process.env.CLOUDANT_API_KEY || "";
const password = process.env.CLOUDANT_API_PASSWORD || "";
const DATABASE = "bfnwallets";
let db;
/*
{
  "apikey": "2f9950cd-d6e8-4398-8f10-546090298325-bluemix-KubFw",
  "host": "2f9950cd-d6e8-4398-8f10-546090298325-bluemix.cloudantnosqldb.appdomain.cloud",
  "iam_apikey_description": "Auto generated apikey during resource-key operation for Instance - crn:v1:bluemix:public:cloudantnosqldb:eu-gb:a/9ae43a022b1d4c2b26ffffdd1bd98293:62e2f020-9322-4055-90b3-0037970de39c::",
  "iam_apikey_name": "auto-generated-apikey-56fe7bea-1440-4736-97e2-8585ef98192e",
  "iam_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Manager",
  "iam_serviceid_crn": "crn:v1:bluemix:public:iam-identity::a/9ae43a022b1d4c2b26ffffdd1bd98293::serviceid:ServiceId-dabe68fe-2a7c-44c2-879c-4e1c4c14a78c",
  "password": "056a61bdb6c9c2e014def6d4cf11fc24f66f7e512db1f2f0c2d667070cfc58f4",
  "port": 443,
  "url": "https://2f9950cd-d6e8-4398-8f10-546090298325-bluemix:056a61bdb6c9c2e014def6d4cf11fc24f66f7e512db1f2f0c2d667070cfc58f4@2f9950cd-d6e8-4398-8f10-546090298325-bluemix.cloudantnosqldb.appdomain.cloud",
  "username": "2f9950cd-d6e8-4398-8f10-546090298325-bluemix"
}
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
        try {
            if (!this.cloudant) {
                this.cloudant = Cloudant({ account, key, password });
            }
            console.log(`💕 💕 cloudant connected : ${DATABASE}   😡  😡  apikey: ${key}`);
            db = this.cloudant.db.use(DATABASE);
        }
        catch (e) {
            console.error(`\n\n👿 👿 👿 👿 cloudant fucked: ${e}\n\n`);
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
                    console.log(`\n\n💕 💕  - db seems OK 💕 💕 ${db} \n\n`);
                }
            }
            catch (e) {
                console.error(`\n\n👿 👿 👿 👿 db failed: 👿 👿 👿 👿\n ${e} \n\n`);
            }
            return {
                apiKey: key,
                account: account,
                password: password
            };
        });
    }
    static insertWalletCache(walletCache) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                const db = this.use();
                db.insert(walletCache, (err, body, header) => {
                    if (err) {
                        console.error(err);
                        reject(null);
                        return;
                    }
                    console.log(`\n\n💙  💚  💛 Document added to cloudant`);
                    console.log(`body: ${body}`);
                    resolve(body);
                });
            });
        });
    }
    static getDocument(_id) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                const db = this.use();
                db.get(_id, (err, data, header) => {
                    if (err) {
                        console.error(err);
                        reject(null);
                        return;
                    }
                    console.log("Get Document");
                    console.log(data);
                    resolve(data);
                });
            });
        });
    }
    static deleteDocument(deleteObj) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                const db = this.use();
                db.destroy(deleteObj._id, deleteObj._rev, (err, body, header) => {
                    if (err) {
                        console.error(err);
                        reject(null);
                        return;
                    }
                    console.log("Delete Document");
                    console.log(body);
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
//# sourceMappingURL=cloudant-controller.js.map