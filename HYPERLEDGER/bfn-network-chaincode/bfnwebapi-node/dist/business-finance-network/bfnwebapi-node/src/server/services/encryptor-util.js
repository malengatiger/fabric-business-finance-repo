"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const CryptoJS = tslib_1.__importStar(require("crypto-js"));
exports.encrypt = (accountID, secret) => tslib_1.__awaiter(this, void 0, void 0, function* () {
    console.log('encryptFunction: ################### encrypt account secret for: ' + accountID);
    try {
        const key = CryptoJS.enc.Utf8.parse(accountID);
        const iv = CryptoJS.enc.Utf8.parse('7061737323313299');
        const encrypted = CryptoJS.AES.encrypt(CryptoJS.enc.Utf8.parse(secret), key, {
            keySize: 128 / 8,
            iv: iv,
            mode: CryptoJS.mode.CBC,
            padding: CryptoJS.pad.Pkcs7
        });
        console.log('ENCRYPTED SECRET : ' + encrypted);
        return '' + encrypted;
    }
    catch (e) {
        console.error(e);
        throw e;
    }
});
//# sourceMappingURL=encryptor-util.js.map