"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let Invoice = class Invoice {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoiceId', String)
], Invoice.prototype, "invoiceId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], Invoice.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('purchaseOrder', String)
], Invoice.prototype, "purchaseOrder", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('invoiceNumber', String)
], Invoice.prototype, "invoiceNumber", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], Invoice.prototype, "date", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('intDate', Number)
], Invoice.prototype, "intDate", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('amount', Number)
], Invoice.prototype, "amount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('purchaseOrderNumber', String)
], Invoice.prototype, "purchaseOrderNumber", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customerName', String)
], Invoice.prototype, "customerName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierName', String)
], Invoice.prototype, "supplierName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customer', String)
], Invoice.prototype, "customer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('totalAmount', Number)
], Invoice.prototype, "totalAmount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('valueAddedTax', Number)
], Invoice.prototype, "valueAddedTax", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplier', String)
], Invoice.prototype, "supplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('isOnOffer', Boolean)
], Invoice.prototype, "isOnOffer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('isSettled', Boolean)
], Invoice.prototype, "isSettled", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('contractURL', String)
], Invoice.prototype, "contractURL", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('deliveryNote', String)
], Invoice.prototype, "deliveryNote", void 0);
Invoice = tslib_1.__decorate([
    json2typescript_1.JsonObject('Invoice')
], Invoice);
exports.Invoice = Invoice;
//# sourceMappingURL=invoice.js.map