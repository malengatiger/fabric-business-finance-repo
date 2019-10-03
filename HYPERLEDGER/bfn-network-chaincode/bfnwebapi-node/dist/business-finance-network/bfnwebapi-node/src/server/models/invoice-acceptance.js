"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let InvoiceAcceptance = class InvoiceAcceptance {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('acceptanceId', String)
], InvoiceAcceptance.prototype, "acceptanceId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], InvoiceAcceptance.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customerName', String)
], InvoiceAcceptance.prototype, "customer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoiceNumber', String)
], InvoiceAcceptance.prototype, "invoiceNumber", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplier', String)
], InvoiceAcceptance.prototype, "supplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierName', String)
], InvoiceAcceptance.prototype, "supplierName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoice', String)
], InvoiceAcceptance.prototype, "invoice", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], InvoiceAcceptance.prototype, "date", void 0);
InvoiceAcceptance = tslib_1.__decorate([
    json2typescript_1.JsonObject('InvoiceAcceptance')
], InvoiceAcceptance);
exports.InvoiceAcceptance = InvoiceAcceptance;
//# sourceMappingURL=invoice-acceptance.js.map