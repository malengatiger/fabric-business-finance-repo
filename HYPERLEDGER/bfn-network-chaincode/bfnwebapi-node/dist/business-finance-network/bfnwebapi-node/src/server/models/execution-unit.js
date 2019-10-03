"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
const auto_trade_order_1 = require("./auto-trade-order");
const investor_profile_1 = require("./investor-profile");
const offer_1 = require("./offer");
const account_1 = require("./account");
let ExecutionUnit = class ExecutionUnit {
    constructor() {
        this.order = new auto_trade_order_1.AutoTradeOrder();
        this.profile = new investor_profile_1.InvestorProfile();
        this.offer = new offer_1.Offer();
        this.account = new account_1.Account();
        this.date = new Date().toISOString();
    }
};
// tslint:disable-next-line:member-ordering
ExecutionUnit.Success = 0;
// tslint:disable-next-line:member-ordering
ExecutionUnit.ErrorInvalidTrade = 1;
// tslint:disable-next-line: member-ordering
ExecutionUnit.ErrorBadBid = 2;
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], ExecutionUnit.prototype, "order", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], ExecutionUnit.prototype, "profile", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], ExecutionUnit.prototype, "offer", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], ExecutionUnit.prototype, "account", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], ExecutionUnit.prototype, "date", void 0);
ExecutionUnit = tslib_1.__decorate([
    json2typescript_1.JsonObject('ExecutionUnit')
], ExecutionUnit);
exports.ExecutionUnit = ExecutionUnit;
//# sourceMappingURL=execution-unit.js.map