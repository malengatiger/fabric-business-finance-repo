"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let DeliveryNote = class DeliveryNote {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('deliveryNoteId', String)
], DeliveryNote.prototype, "deliveryNoteId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], DeliveryNote.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customer', String)
], DeliveryNote.prototype, "customer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('user', String)
], DeliveryNote.prototype, "user", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplier', String)
], DeliveryNote.prototype, "supplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierName', String)
], DeliveryNote.prototype, "supplierName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], DeliveryNote.prototype, "date", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('amount', Number)
], DeliveryNote.prototype, "amount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('vat', Number)
], DeliveryNote.prototype, "vat", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('totalAmount', Number)
], DeliveryNote.prototype, "totalAmount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierDocumentRef', String)
], DeliveryNote.prototype, "supplierDocumentRef", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('purchaseOrderNumber', String)
], DeliveryNote.prototype, "purchaseOrderNumber", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customerName', String)
], DeliveryNote.prototype, "customerName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('purchaseOrder', String)
], DeliveryNote.prototype, "purchaseOrder", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('intDate', Number)
], DeliveryNote.prototype, "intDate", void 0);
DeliveryNote = tslib_1.__decorate([
    json2typescript_1.JsonObject('DeliveryNote')
], DeliveryNote);
exports.DeliveryNote = DeliveryNote;
//# sourceMappingURL=delivery-note.js.map