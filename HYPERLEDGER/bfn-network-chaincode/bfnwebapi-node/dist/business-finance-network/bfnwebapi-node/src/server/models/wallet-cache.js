"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let WalletCache = class WalletCache {
    constructor() {
        this._id = '';
        this.userContent = '';
        this.privateKey = '';
        this.publicKey = '';
        this.date = new Date().toISOString();
        this.secret = '';
        this.userFileName = '';
        this.publicKeyFileName = '';
        this.privateKeyFileName = '';
    }
    toJson() {
        return {
            _id: this._id,
            userContent: this.userContent,
            privateKey: this.privateKey,
            publicKey: this.publicKey,
            date: this.date,
            secret: this.secret,
            publicKeyFileName: this.publicKeyFileName,
            privateKeyFileName: this.privateKeyFileName,
            userFileName: this.userFileName
        };
    }
    fromJson(json) {
        this._id = json._id;
        this.date = json.date;
        this.userContent = json.userContent;
        this.privateKey = json.privateKey;
        this.publicKey = json.publicKey;
        this.secret = json.secret;
        this.userFileName = json.userFileName;
        this.publicKeyFileName = json.publicKeyFileName;
        this.privateKeyFileName = json.privateKeyFileName;
    }
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "_id", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "userContent", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "privateKey", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "publicKey", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "date", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "secret", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "userFileName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "publicKeyFileName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], WalletCache.prototype, "privateKeyFileName", void 0);
WalletCache = tslib_1.__decorate([
    json2typescript_1.JsonObject("WalletCache")
], WalletCache);
exports.WalletCache = WalletCache;
//# sourceMappingURL=wallet-cache.js.map