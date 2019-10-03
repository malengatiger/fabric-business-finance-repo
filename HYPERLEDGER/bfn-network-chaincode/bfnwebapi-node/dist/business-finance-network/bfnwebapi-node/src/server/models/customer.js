"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let Customer = class Customer {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], Customer.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('participantId', String)
], Customer.prototype, "participantId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('name', String)
], Customer.prototype, "name", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('cellphone', String)
], Customer.prototype, "cellphone", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('email', String)
], Customer.prototype, "email", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('documentReference', String)
], Customer.prototype, "documentReference", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('description', String)
], Customer.prototype, "description", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('address', String)
], Customer.prototype, "address", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('dateRegistered', String)
], Customer.prototype, "dateRegistered", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('sector', String)
], Customer.prototype, "sector", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('country', String)
], Customer.prototype, "country", void 0);
Customer = tslib_1.__decorate([
    json2typescript_1.JsonObject('Customer')
], Customer);
exports.Customer = Customer;
//# sourceMappingURL=customer.js.map