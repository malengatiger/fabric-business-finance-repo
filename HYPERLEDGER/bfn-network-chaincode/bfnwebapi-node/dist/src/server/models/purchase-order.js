"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let PurchaseOrder = class PurchaseOrder {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], PurchaseOrder.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('purchaseOrderId', String)
], PurchaseOrder.prototype, "purchaseOrderId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplier', String)
], PurchaseOrder.prototype, "supplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customer', String)
], PurchaseOrder.prototype, "customer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], PurchaseOrder.prototype, "date", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('intDate', Number)
], PurchaseOrder.prototype, "intDate", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('amount', Number)
], PurchaseOrder.prototype, "amount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('purchaseOrderNumber', String)
], PurchaseOrder.prototype, "purchaseOrderNumber", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customerName', String)
], PurchaseOrder.prototype, "customerName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierName', String)
], PurchaseOrder.prototype, "supplierName", void 0);
PurchaseOrder = tslib_1.__decorate([
    json2typescript_1.JsonObject('PurchaseOrder')
], PurchaseOrder);
exports.PurchaseOrder = PurchaseOrder;
//# sourceMappingURL=purchase-order.js.map