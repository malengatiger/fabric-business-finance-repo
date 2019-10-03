"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let Investor = class Investor {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], Investor.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('participantId', String)
], Investor.prototype, "participantId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('name', String)
], Investor.prototype, "name", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('cellphone', String)
], Investor.prototype, "cellphone", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('email', String)
], Investor.prototype, "email", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('documentReference', String)
], Investor.prototype, "documentReference", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('description', String)
], Investor.prototype, "description", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('address', String)
], Investor.prototype, "address", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('dateRegistered', String)
], Investor.prototype, "dateRegistered", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('sector', String)
], Investor.prototype, "sector", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('country', String)
], Investor.prototype, "country", void 0);
Investor = tslib_1.__decorate([
    json2typescript_1.JsonObject('Investor')
], Investor);
exports.Investor = Investor;
//# sourceMappingURL=investor.js.map