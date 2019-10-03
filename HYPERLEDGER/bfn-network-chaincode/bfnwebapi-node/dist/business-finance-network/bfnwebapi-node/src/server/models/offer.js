"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let Offer = class Offer {
    constructor() {
        this.invoiceAmount = 0.0;
        this.offerAmount = 0.0;
        this.discountPercent = 0.0;
        this.isCancelled = false;
        this.isOpen = true;
    }
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], Offer.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('offerId', String)
], Offer.prototype, "offerId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('intDate', Number)
], Offer.prototype, "intDate", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('startTime', String)
], Offer.prototype, "startTime", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('endTime', String)
], Offer.prototype, "endTime", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('offerCancellation', String)
], Offer.prototype, "offerCancellation", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoice', String)
], Offer.prototype, "invoice", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('documentReference', String)
], Offer.prototype, "documentReference", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('purchaseOrder', String)
], Offer.prototype, "purchaseOrder", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('participantId', String)
], Offer.prototype, "participantId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('wallet', String)
], Offer.prototype, "wallet", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('user', String)
], Offer.prototype, "user", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], Offer.prototype, "date", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplier', String)
], Offer.prototype, "supplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('contractURL', String)
], Offer.prototype, "contractURL", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoiceDocumentRef', String)
], Offer.prototype, "invoiceDocumentRef", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierName', String)
], Offer.prototype, "supplierName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customerName', String)
], Offer.prototype, "customerName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customer', String)
], Offer.prototype, "customer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('dateClosed', String)
], Offer.prototype, "dateClosed", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoiceAmount', Number)
], Offer.prototype, "invoiceAmount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('offerAmount', Number)
], Offer.prototype, "offerAmount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('discountPercent', Number)
], Offer.prototype, "discountPercent", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('isCancelled', Boolean)
], Offer.prototype, "isCancelled", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('isOpen', Boolean)
], Offer.prototype, "isOpen", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('sector', String)
], Offer.prototype, "sector", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('sectorName', String)
], Offer.prototype, "sectorName", void 0);
Offer = tslib_1.__decorate([
    json2typescript_1.JsonObject('Offer')
], Offer);
exports.Offer = Offer;
//# sourceMappingURL=offer.js.map