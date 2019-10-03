import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import {
  X509WalletMixin,
  FileSystemWallet,
  IdentityInfo,
  InMemoryWallet,
  Identity
} from "fabric-network";
import { CloudantService } from "./cloudant-service";
import { WalletCache } from "../models/wallet-cache";
const z = "\n";
export class WalletHelper {
  public static async writeFile(contents: string, filePath: string) {
    console.log(`☕️ ☕️ ☕️ write file ${filePath} ...`);
    try {
      fs.writeFile(filePath, contents, err => {
        if (err) {
          console.log(`File write failed ${err}`);
          throw new Error(`Failed to write file ${err}`);
        }
        console.log(`💙 💕💕💕 file written successfully: ${filePath}`);
        return null;
      });
    } catch (e) {
      console.log(`File write failed ${e}`);
      throw new Error(`Failed to write file ${e}`);
    }
  }
  public static async getTemporayDirectory() {
    // console.log(`☕️ ☕️ Getting temporary directory`);
    let temporaryDirectory: string;
    try {
      temporaryDirectory = fs.mkdtempSync(
        path.join(os.tmpdir(), "wallet" + new Date().getTime())
      );
      fs.chmod(temporaryDirectory, "755", function (err) {
        if (err) {
          throw new Error(`👿 👿 👿 Problem with temp dir ${err}`);
        } else {
          // console.log(
          //   `🔵 🔵 temporary directory ready to rumble: ${temporaryDirectory}`
          // );
          return temporaryDirectory;
        }
      });
    } catch (e) {
      console.log(`👿 👿 👿 Problem getting directory ${e}`);
      throw e;
    }
    return temporaryDirectory;
  }

  public static async getAdminWallet(): Promise<FileSystemWallet> {

    const ADMIN_USER = "org1admin";

    const dir = await this.getTemporayDirectory();
    let wallet: FileSystemWallet = new FileSystemWallet(dir);

    let mspId: string;
    let certif: string;
    let privateKey: string;

    const start1 = new Date().getTime();
    const obj: any = await CloudantService.getWalletCache(ADMIN_USER);
    const start2 = new Date().getTime();
    const elapsed1 = (start2 - start1) / 1000
    let cache: WalletCache;
    if (obj.cache) {
      cache = obj.cache;
      const userContentJson = JSON.parse(cache.userContent);
      mspId = userContentJson.mspid;
      certif = userContentJson.enrollment.identity.certificate;
      privateKey = cache.privateKey;

      const identity = X509WalletMixin.createIdentity(
        mspId,
        certif,
        privateKey
      );
      const start3 = new Date().getTime();
      wallet = new FileSystemWallet(dir);
      await wallet.import(ADMIN_USER, identity);
      const start4 = new Date().getTime();
      const exists = await wallet.exists(ADMIN_USER);
      if (exists) {
        // console.log(
        //   `${z}${z}💓 💓 💓 💓 recovered admin wallet exists! 🤖 🤖 🤖 🤖 we should have a fucking 💚 party!\n\n`
        // );
      } else {
        const msg = `${z}${z}👿 👿 👿 👿 👿 👿 FAILED. 😡 admin wallet no mas, Senor!`;
        console.error(msg);
        throw new Error(msg);
      }
     
    }
    const start6 = new Date().getTime();
    const elapsed3 = (start6 - start1) / 1000
    console.log(`⌛️ ⌛️ ⌛️   wallet recovery took ${elapsed3} seconds`)

    return wallet;
  }

  public static async getFileSystemWallet(
    userName: string
  ): Promise<FileSystemWallet> {
   
    let imWallet: FileSystemWallet;
    let mspId: string;
    let certif: string;
    let privateKey: string;

    const obj: any = await CloudantService.getWalletCache(userName);
    let cache: WalletCache;

    if (obj.cache) {
      cache = obj.cache;
      const userContentJson = JSON.parse(cache.userContent);
      mspId = userContentJson.mspid;
      certif = userContentJson.enrollment.identity.certificate;
      privateKey = cache.privateKey;
      const identity: Identity = X509WalletMixin.createIdentity(
        mspId,
        certif,
        privateKey
      );

      const walletPath = path.join(process.cwd(), `wallet${userName}${new Date().getTime()}`);
      const dir = fs.mkdtempSync(walletPath);
      imWallet = new FileSystemWallet(dir);
      // console.log(`${z} 💦 💦 💦  Importing wallet ... `);
      await imWallet.import(userName, identity);
      const exists = await imWallet.exists(userName);
      if (!exists) {
        const msg = `${z}👿  👿  👿 An identity for the user ${userName} does not exist in the wallet${z}`;
        console.error(msg);
        throw new Error(msg);
      }
      console.log(
        `💕 💕  💕 💕  💕 💕  💕 💕   user wallet is CREATED OK ....`
      );
      return imWallet;
    } else {
      throw new Error(`👿  👿  👿  User wallet recovery failed`);
    }
  }
}
