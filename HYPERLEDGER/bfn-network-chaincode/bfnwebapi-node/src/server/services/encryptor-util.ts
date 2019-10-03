import * as CryptoJS from 'crypto-js';
export const encrypt = async (accountID: string, secret: string) =>  {
    console.log('encryptFunction: ################### encrypt account secret for: ' + accountID)
    try {
        const key = CryptoJS.enc.Utf8.parse(accountID);
        const iv = CryptoJS.enc.Utf8.parse('7061737323313299');

        const encrypted = CryptoJS.AES.encrypt(
            CryptoJS.enc.Utf8.parse(secret), key,
            {
                keySize: 128 / 8,
                iv: iv,
                mode: CryptoJS.mode.CBC,
                padding: CryptoJS.pad.Pkcs7
            });
        console.log('ENCRYPTED SECRET : ' + encrypted);
        return '' + encrypted

    } catch (e) {
        console.error(e)
        throw e
    }
}