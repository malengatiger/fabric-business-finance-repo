"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let DeliveryAcceptance = class DeliveryAcceptance {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('acceptanceId', String)
], DeliveryAcceptance.prototype, "acceptanceId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], DeliveryAcceptance.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customer', String)
], DeliveryAcceptance.prototype, "customer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('customerName', String)
], DeliveryAcceptance.prototype, "customerName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('deliveryNote', String)
], DeliveryAcceptance.prototype, "deliveryNote", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplier', String)
], DeliveryAcceptance.prototype, "supplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('supplierName', String)
], DeliveryAcceptance.prototype, "supplierName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('purchaseOrder', String)
], DeliveryAcceptance.prototype, "purchaseOrder", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], DeliveryAcceptance.prototype, "date", void 0);
DeliveryAcceptance = tslib_1.__decorate([
    json2typescript_1.JsonObject('DeliveryAcceptance')
], DeliveryAcceptance);
exports.DeliveryAcceptance = DeliveryAcceptance;
//# sourceMappingURL=delivery-acceptance.js.map