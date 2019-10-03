"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let Wallet = class Wallet {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], Wallet.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('dateRegistered', String)
], Wallet.prototype, "dateRegistered", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('name')
], Wallet.prototype, "name", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customer', String)
], Wallet.prototype, "customer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplier', String)
], Wallet.prototype, "supplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investor', String)
], Wallet.prototype, "investor", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('oneConnect', String)
], Wallet.prototype, "oneConnect", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('stellarPublicKey')
], Wallet.prototype, "stellarPublicKey", void 0);
Wallet = tslib_1.__decorate([
    json2typescript_1.JsonObject('Wallet')
], Wallet);
exports.Wallet = Wallet;
//# sourceMappingURL=wallet.js.map