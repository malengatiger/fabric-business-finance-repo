"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let AutoTradeOrder = class AutoTradeOrder {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], AutoTradeOrder.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('name', String)
], AutoTradeOrder.prototype, "name", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('autoTradeOrderId', String)
], AutoTradeOrder.prototype, "autoTradeOrderId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], AutoTradeOrder.prototype, "date", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investorName', String)
], AutoTradeOrder.prototype, "investorName", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('dateCancelled', String)
], AutoTradeOrder.prototype, "dateCancelled", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('wallet', String)
], AutoTradeOrder.prototype, "wallet", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investorProfile', String)
], AutoTradeOrder.prototype, "investorProfile", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('user', String)
], AutoTradeOrder.prototype, "user", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investor', String)
], AutoTradeOrder.prototype, "investor", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('isCancelled', Boolean)
], AutoTradeOrder.prototype, "isCancelled", void 0);
AutoTradeOrder = tslib_1.__decorate([
    json2typescript_1.JsonObject('AutoTradeOrder')
], AutoTradeOrder);
exports.AutoTradeOrder = AutoTradeOrder;
//# sourceMappingURL=auto-trade-order.js.map