// ###################################################################################
// Request Certificates from CA and Register admin user, save wallet in cloud storage
// ###################################################################################

import * as fs from "fs";
import FabricCAServices from "fabric-ca-client";
import {
  FileSystemWallet,
  X509WalletMixin,
  Contract,
  Transaction,
} from "fabric-network";
import { WalletHelper } from "./wallet-helper";
import { CloudantService } from "./cloudant-service";
import { WalletCache } from "../models/wallet-cache";
import { ConnectToChaincode } from "./connection";
import { Constants } from '../models/constants';
//
const adminUser = "org1admin";
let organization = "org1msp";
let caURL: string;
let enrollSecret = "org1adminpw";
let temporaryWalletDirectory: string = "";

//curl --header "Content-Type: application/json"   --request POST   --data '{"debug": "true"}'   https://us-central1-business-finance-dev.cloudfunctions.net/registerAdmin
//let userName: string;
const z = "\n";
/*
Register admin user and save creds in Cloudant database
*/
export class AdminRegistrationSevice {
  public static async enrollAdmin() {
    console.log(
      `🔵 🔵 🔵 🔵  REGISTER BFN ADMIN USER starting .... 🔵 🔵 🔵 🔵`
    );
    const profile = await CloudantService.getConnectionProfile();
    if (!profile) {
      const msg = '😡 😡 Unable to get connection profile from 💦 💦 Cloudant'
      console.error(msg);
      throw new Error(msg);
    }
    console.log(profile);
    const keysArray = Object.keys(profile.certificateAuthorities);
    let mValue;
    for (var i = 0; i < keysArray.length; i++) {
      var key = keysArray[i];
      mValue = profile.certificateAuthorities[key];
    }
    organization = profile.client.organization
    console.log(`💚 💚   organization from profile : 🎁 ${organization}`);
    if (mValue) {
      caURL = mValue.url;
      console.log(
        `🤢 🤢   certificateAuthority url from cloudant:  🔑 🔑 🔑 ${
        mValue.url
        }`
      );
    } else {
      console.log(
        `🔵 🔵 default certificateAuthority url: ${caURL}`
      );
    }

    try {
      temporaryWalletDirectory = await WalletHelper.getTemporayDirectory();
      const ca = new FabricCAServices(caURL);
      const wallet = new FileSystemWallet(temporaryWalletDirectory);

      //Enroll the admin user, and import the new identity into the wallet.
      console.log("🔵 🔵  enrolling ...................");
      const enrollment = await ca.enroll({
        enrollmentID: adminUser,
        enrollmentSecret: enrollSecret
      });
      console.log(
        `💚 💚 💚  admin user enrolled on certificate authority - enrollment.key:  ${enrollment.key.toBytes()}   💚 💚 💚 `
      );

      const identity = X509WalletMixin.createIdentity(
        organization,
        enrollment.certificate,
        enrollment.key.toBytes()
      );

      await wallet.import(adminUser, identity);
      console.log(
        `${z}✅ 💛 💛  Successfully enrolled admin user: 💚 ${adminUser}  ${
        identity.type
        }  
        💚 imported certs into wallet 💛 💛 💛`
      );

      console.log(`${z}${z}💦  💦  💦  Upload wallet to Cloudant .... `);

      const msg = await AdminRegistrationSevice.uploadWallet();
      return msg;
    } catch (error) {
      const msg = `👿👿👿 Failed to enroll admin user ${adminUser}: ${error}  👿👿`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async uploadWallet() {
    console.log(
      `🔵  🔵  uploading ${temporaryWalletDirectory} wallet directory files to Firesreto ... 🔵  🔵`
    );
    await fs.readdir(temporaryWalletDirectory, async function (err, files) {
      if (err) {
        console.error(`👿 👿  Could not list the directory.`, err);
        throw new Error(
          "👿 👿  Failed to list temporary directory files containg identity"
        );
      } else {
        const directoryFromCA = temporaryWalletDirectory + "/" + files[0];
        let isDirectory = false;
        try {
          isDirectory = fs.lstatSync(directoryFromCA).isDirectory();
        } catch (e) {
          throw new Error(
            "👿👿  Failed to check temporary directory files containg identity"
          );
        }

        if (isDirectory) {
          return await AdminRegistrationSevice.uploadFiles(directoryFromCA);
        } else {
          console.log(
            "⚠️ ⚠️ ⚠️  WTF, only one file created by CA, expected 3 inside directory"
          );
          throw new Error("⚠️  WTF, only one file created by CA, expected 3");
        }
      }
    });
    return `💙  💚  💛  💙  💚  💛  we be pretty cool, Bro!`;
  }
  private static async uploadFiles(directoryFromCA: string) {
    let cnt = 0;
    const cache: WalletCache = new WalletCache();

    fs.readdir(directoryFromCA, async function (error, fileList) {
      console.log(
        `${z}🔵  🔵 CA directory has: ` +
        fileList.length +
        " files. Should be 3 💕 💕 💕 of them!"
      );
      if (!error) {
        for (const file of fileList) {
          const mpath = directoryFromCA + "/" + file;
          console.log(
            `${z}😡 😡 - reading file: ${file} for saving in cloudant ... 😡 😡 `
          );
          const buffer = fs.readFileSync(mpath);
          const fileContents = buffer.toString("utf8");
          const privateKey = fileContents.search("PRIVATE");
          const publicKey = fileContents.search("PUBLIC");
          if (privateKey > -1) {
            cache.privateKeyFileName = file;
            cache.privateKey = fileContents;
          } else {
            if (publicKey > -1) {
              cache.publicKey = fileContents;
              cache.publicKeyFileName = file;
            } else {
              cache.userContent = fileContents;
              cache.userFileName = file;
            }
          }
          cnt++;
        }

        cache._id = adminUser;
        cache.date = new Date().toISOString();

        await CloudantService.insertWalletCache(cache);

        const msg = `${z}🔵 🔵 🔵 🔵  Blockchain Admin User enrolled, wallet identity files uploaded and cached: 💕💕  ${cnt}   💕💕`;
        console.log(msg);
        // test wallet recovery from cloudant
        console.log(`${z}🔵 🔵 🔵 🔵  ############ TESTING WALLET RECOVERY #################  🔵 🔵 🔵 🔵  ${z}`)
        const recWallet = await WalletHelper.getFileSystemWallet(adminUser);
        const contract: Contract = await ConnectToChaincode.getContract(
          adminUser,
          recWallet
        );
        if (contract) {
          console.log(
            `${z}❤️  ❤️  ❤️  Received contract object OK. Yes!! ❤️  ❤️  ❤️ ${z}`
          );
          const tx: Transaction = contract.createTransaction('init');
          console.log(`${z}💦  💦  💦   transaction name: ${tx.getName()} txId: ${tx.getTransactionID().getTransactionID()}`);
          const payload: Buffer = await tx.submit();
          console.log(`${z}  ☕️  ☕️  ☕️  ☕️  tx.submit - Payload: ${z}${payload.toString()}`);
          const payload2: Buffer = await contract.submitTransaction('init');
          console.log(`${z}  ☕️  ☕️  ☕️  ☕️  contract.submitTransaction - Payload: ${z}${payload2.toString()}`);
        }
        return msg;
      } else {
        const msg = `${z}👿👿👿 Error reading wallet directory 👿👿👿${z}`;
        console.log(msg);
        throw new Error(msg);
      }
    });
  }
}
