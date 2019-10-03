"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let InvalidSummary = class InvalidSummary {
    constructor() {
        this.isValidInvoiceAmount = 0;
        this.isValidBalance = 0;
        this.isValidSector = 0;
        this.isValidSupplier = 0;
        this.isValidMinimumDiscount = 0;
        this.isValidInvestorMax = 0;
        this.invalidTrades = 0;
        this.totalOpenOffers = 0;
        this.totalUnits = 0;
        this.date = new Date().toISOString();
    }
    toJSON() {
        return {
            isValidBalance: this.isValidBalance,
            isValidInvoiceAmount: this.isValidInvoiceAmount,
            isValidSector: this.isValidSector,
            isValidSupplier: this.isValidSupplier,
            // tslint:disable-next-line:object-literal-sort-keys
            isValidMinimumDiscount: this.isValidMinimumDiscount,
            isValidInvestorMax: this.isValidInvestorMax,
            invalidTrades: this.invalidTrades,
            totalOpenOffers: this.totalOpenOffers,
            totalUnits: this.totalUnits,
            date: this.date,
        };
    }
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "isValidInvoiceAmount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "isValidBalance", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "isValidSector", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "isValidSupplier", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "isValidMinimumDiscount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "isValidInvestorMax", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "invalidTrades", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "totalOpenOffers", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "totalUnits", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], InvalidSummary.prototype, "date", void 0);
InvalidSummary = tslib_1.__decorate([
    json2typescript_1.JsonObject('InvalidSummary')
], InvalidSummary);
exports.InvalidSummary = InvalidSummary;
//# sourceMappingURL=invalid-summary.js.map