"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let InvoiceBid = class InvoiceBid {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], InvoiceBid.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoiceBidId', String)
], InvoiceBid.prototype, "invoiceBidId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('startTime', String)
], InvoiceBid.prototype, "startTime", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('endTime', String)
], InvoiceBid.prototype, "endTime", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('reservePercent', Number)
], InvoiceBid.prototype, "reservePercent", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('amount', Number)
], InvoiceBid.prototype, "amount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('discountPercent', Number)
], InvoiceBid.prototype, "discountPercent", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('offer', String)
], InvoiceBid.prototype, "offer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierFCMToken', String)
], InvoiceBid.prototype, "supplierFCMToken", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('wallet', String)
], InvoiceBid.prototype, "wallet", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investor', String)
], InvoiceBid.prototype, "investor", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], InvoiceBid.prototype, "date", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('autoTradeOrder', String)
], InvoiceBid.prototype, "autoTradeOrder", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('user', String)
], InvoiceBid.prototype, "user", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('documentReference', String)
], InvoiceBid.prototype, "documentReference", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplier', String)
], InvoiceBid.prototype, "supplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoiceBidAcceptance', String)
], InvoiceBid.prototype, "invoiceBidAcceptance", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investorName', String)
], InvoiceBid.prototype, "investorName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('isSettled', Boolean)
], InvoiceBid.prototype, "isSettled", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierName', String)
], InvoiceBid.prototype, "supplierName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customerName', String)
], InvoiceBid.prototype, "customerName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customer', String)
], InvoiceBid.prototype, "customer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierDocRef', String)
], InvoiceBid.prototype, "supplierDocRef", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('offerDocRef', String)
], InvoiceBid.prototype, "offerDocRef", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investorDocRef', String)
], InvoiceBid.prototype, "investorDocRef", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('intDate', Number)
], InvoiceBid.prototype, "intDate", void 0);
InvoiceBid = tslib_1.__decorate([
    json2typescript_1.JsonObject('InvoiceBid')
], InvoiceBid);
exports.InvoiceBid = InvoiceBid;
//# sourceMappingURL=invoice-bid.js.map