"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let Supplier = class Supplier {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType')
], Supplier.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('participantId')
], Supplier.prototype, "participantId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('name', String)
], Supplier.prototype, "name", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('cellphone', String)
], Supplier.prototype, "cellphone", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('email', String)
], Supplier.prototype, "email", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('documentReference', String)
], Supplier.prototype, "documentReference", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('description', String)
], Supplier.prototype, "description", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('address', String)
], Supplier.prototype, "address", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('dateRegistered', String)
], Supplier.prototype, "dateRegistered", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('sector', String)
], Supplier.prototype, "sector", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('country', String)
], Supplier.prototype, "country", void 0);
Supplier = tslib_1.__decorate([
    json2typescript_1.JsonObject('Supplier')
], Supplier);
exports.Supplier = Supplier;
//# sourceMappingURL=supplier.js.map