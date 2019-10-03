"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const MyCrypto = tslib_1.__importStar(require("./encryptor-util"));
class Encrypt {
    static encrypt(accountID, secret) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log("################### encrypt account secret for: " + accountID);
            try {
                const encrypted = yield MyCrypto.encrypt(accountID, secret);
                return "" + encrypted;
            }
            catch (e) {
                console.error(e);
                throw e;
            }
        });
    }
}
exports.Encrypt = Encrypt;
//# sourceMappingURL=encryptor.js.map