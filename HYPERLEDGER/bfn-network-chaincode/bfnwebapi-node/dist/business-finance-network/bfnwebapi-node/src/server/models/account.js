"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const json2typescript_1 = require("json2typescript");
let Balance = class Balance {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], Balance.prototype, "balance", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], Balance.prototype, "asset_type", void 0);
Balance = tslib_1.__decorate([
    json2typescript_1.JsonObject("Balance")
], Balance);
exports.Balance = Balance;
let Account = class Account {
};
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], Account.prototype, "id", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], Account.prototype, "paging_token", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], Account.prototype, "account_id", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], Account.prototype, "sequence", void 0);
tslib_1.__decorate([
    json2typescript_1.JsonProperty()
], Account.prototype, "balances", void 0);
Account = tslib_1.__decorate([
    json2typescript_1.JsonObject("Account")
], Account);
exports.Account = Account;
//# sourceMappingURL=account.js.map