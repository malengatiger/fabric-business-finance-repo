// ###################################################################################
// Request Certificates from CA and Register admin user, save wallet in cloud storage
// ###################################################################################

import * as fs from "fs";
import FabricCAServices from "fabric-ca-client";
import {
  FileSystemWallet,
  X509WalletMixin,
  Gateway,
  Network,
  Contract,
  Transaction
} from "fabric-network";
import { WalletHelper } from "./wallet-helper";
import { CloudantService } from "./cloudant-service";
import { WalletCache } from "../models/wallet-cache";
import { TransactionService } from './transaction-service';
import { Constants } from '../models/constants';
//

// expected parameters received in json data structure
let organization = "org1msp";
let caURL =
  "https://6a8196c6cae84bbaa5b4606fbaba63a8-ca8f5ceb.bfncluster.us-south.containers.appdomain.cloud:7054"; //certificate authority url - from blockchain connection profile json file
let enrollSecret = "adminpw";
let temporaryWalletDirectory: string = "";

//curl --header "Content-Type: application/json"   --request POST   --data '{"debug": "true"}'   https://us-central1-business-finance-dev.cloudfunctions.net/registerAdmin
const z = "\n";
let mUser: any;
/*
Register user and save creds in Cloudant database
*/
export class UserRegistrationSevice {
  
  public static async enrollUser(jsonString: string) {
    console.log(
      `${z}🔵 🔵 🔵 🔵  REGISTER BFN USER ${jsonString}  starting .... 🔵 🔵 🔵 🔵${z}`
    );
    //
    mUser = JSON.parse(jsonString);
    const config = await CloudantService.getConfig();
    organization = config.orgMSPID;
    console.log(`${z} ${z} 💚 💚   organization from config : ${organization}`)
    //
    const m = await CloudantService.getConnectionProfile();
    const keysArray = Object.keys(m.certificateAuthorities);
    let mValue;
    for (var i = 0; i < keysArray.length; i++) {
      var key = keysArray[i]; 
      mValue = m.certificateAuthorities[key]; 
    }

    if (mValue) {
      caURL = mValue.url;
      console.log(
        `${z}🤢 🤢   certificateAuthority url from cloudant:  ${z}${z}${
          mValue.url
        }`
      );
    } else {
      console.log(`${z}🔵 🔵 default certificateAuthority url: ${z}${z}${caURL}`);
    }

    // const buff = Buffer.from(betaCert64, "base64");
    // const betaCert = buff.toString("ascii");
    // const buff2 = Buffer.from(betaKey64, "base64");
    // const betaKey = buff2.toString("ascii");

    try {
      temporaryWalletDirectory = await WalletHelper.getTemporayDirectory();
      const ca = new FabricCAServices(caURL);
      const wallet = new FileSystemWallet(temporaryWalletDirectory);

      //Enroll the user, and import the new identity into the wallet.

      console.log(`${z}🔵 🔵  enrolling ${jsonString} ...................`);
      const enrollment = await ca.enroll({
        enrollmentID: mUser.userName,
        enrollmentSecret: mUser.secret
      });

      console.log(
        `${z}${z}💚 💚 💚  ${mUser.userName} enrolled on certificate authority - enrollment.key:  ${
          enrollment.key.toBytes()
        }   💚 💚 💚 `
      );
     
      const identity = X509WalletMixin.createIdentity(
        organization,
        enrollment.certificate,
        enrollment.key.toBytes()
      );

      await wallet.import(mUser.userName, identity);
      console.log(
        `${z}✅ 💛 💛  Successfully enrolled user: 💚 ${mUser.userName}  ${
          identity.type
        }  
        💚 imported certs into wallet 💛 💛 💛`
      );
      return await this.uploadWallet(mUser.userName);
    } catch (error) {
      const msg = ` 👿  👿  👿   Failed to enroll user ${mUser}: ${error}  👿  👿`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async uploadWallet(userName: string) {
    console.log(
      `${z}🔵  🔵  uploading ${temporaryWalletDirectory} wallet directory files to cloudant ... 🔵  🔵`
    );
    fs.readdir(temporaryWalletDirectory, async function(err, files) {
      if (err) {
        console.error(`${z}👿 👿  Could not list the directory.`, err);
        throw new Error(
          " 👿 👿  Failed to list temporary directory files containg identity"
        );
      } else {
        const directoryFromCA = temporaryWalletDirectory + "/" + files[0];
        let isDirectory = false;
        try {
          isDirectory = fs.lstatSync(directoryFromCA).isDirectory();
        } catch (e) {
          throw new Error(
            " 👿 👿  Failed to check temporary directory files containg identity"
          );
        }

        if (isDirectory) {
          return await UserRegistrationSevice.uploadFiles(userName,directoryFromCA);
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
  private static async uploadFiles(userName: string, directoryFromCA: string) {
    let cnt = 0;
    const cache: WalletCache = new WalletCache();

    fs.readdir(directoryFromCA, async function(error, fileList) {
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
       
        
        cache._id = userName;
        cache.date = new Date().toISOString();

        await CloudantService.insertWalletCache(cache);

        const msg =  `${z}🔵 🔵 🔵 🔵  Blockchain User enrolled, wallet identity files uploaded and cached: 💕💕  ${cnt}   💕💕`;
        const user = await TransactionService.send(Constants.DEFAULT_USERNAME, Constants.CHAIN_ADD_USER, mUser);
        console.log(`user processed: ${user}`);
        console.log(msg);
        return msg;
      } else {
        const msg = `${z}👿👿👿 Error reading wallet directory 👿👿👿${z}`;
        console.log(msg);
        throw new Error(msg);
      }
    });
  }
}
