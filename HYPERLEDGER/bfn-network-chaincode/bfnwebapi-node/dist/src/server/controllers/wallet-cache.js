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
    }
    toJson() {
        return {
            _id: this._id,
            userContent: this.userContent,
            privateKey: this.privateKey,
            publicKey: this.publicKey,
            date: this.date
        };
    }
    fromJson(json) {
        this._id = json._id;
        this.date = json.date;
        this.userContent = json.userContent;
        this.privateKey = json.privateKey;
        this.publicKey = json.publicKey;
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
WalletCache = tslib_1.__decorate([
    json2typescript_1.JsonObject("WalletCache")
], WalletCache);
exports.WalletCache = WalletCache;
//# sourceMappingURL=wallet-cache.js.map