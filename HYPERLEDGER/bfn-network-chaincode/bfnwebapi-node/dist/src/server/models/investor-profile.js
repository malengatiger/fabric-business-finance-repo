"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let InvestorProfile = class InvestorProfile {
    constructor() {
        this.maxInvestableAmount = 0.0;
        this.maxInvoiceAmount = 0.0;
        this.minimumDiscount = 0.0;
        this.sectors = [];
        this.suppliers = [];
        this.totalBidAmount = 0.0;
    }
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty('docType', String)
], InvestorProfile.prototype, "docType", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('profileId', String)
], InvestorProfile.prototype, "profileId", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('name', String)
], InvestorProfile.prototype, "name", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('cellphone', String)
], InvestorProfile.prototype, "cellphone", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('email', String)
], InvestorProfile.prototype, "email", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('date', String)
], InvestorProfile.prototype, "date", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('maxInvestableAmount', Number)
], InvestorProfile.prototype, "maxInvestableAmount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('maxInvoiceAmount', Number)
], InvestorProfile.prototype, "maxInvoiceAmount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('minimumDiscount', Number)
], InvestorProfile.prototype, "minimumDiscount", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investor', String)
], InvestorProfile.prototype, "investor", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('investorDocRef', String)
], InvestorProfile.prototype, "investorDocRef", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('sectors', Array)
], InvestorProfile.prototype, "sectors", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('suppliers', Array)
], InvestorProfile.prototype, "suppliers", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty('totalBidAmount', Number)
], InvestorProfile.prototype, "totalBidAmount", void 0);
InvestorProfile = tslib_1.__decorate([
    json2typescript_1.JsonObject('InvestorProfile')
], InvestorProfile);
exports.InvestorProfile = InvestorProfile;
//# sourceMappingURL=investor-profile.js.map