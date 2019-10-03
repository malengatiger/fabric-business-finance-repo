import * as MyCrypto from "./encryptor-util";

export class Encrypt {
  public static async encrypt(accountID: string, secret: string) {
    console.log("################### encrypt account secret for: " + accountID);
    try {
      const encrypted = await MyCrypto.encrypt(accountID, secret);
      return "" + encrypted;
    } catch (e) {
      console.error(e);
      throw e;
    }
  }
}
