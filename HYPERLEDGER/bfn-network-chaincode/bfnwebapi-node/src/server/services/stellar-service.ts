import * as admin from "firebase-admin";
import * as MyCrypto from "./encryptor-util";
import * as requestor from "request";
import { Constants } from '../models/constants';
import { TransactionService } from './transaction-service';
const StellarSdk = require("stellar-sdk");
const sourceSeed = '';
const debug: boolean = true;
const STARTING_BALANCE = "3";

export class StellarWalletService {

  public static async createWallet(participantId: string): Promise<any> {
    const firestore = admin.firestore();

    console.log("💥 💥 💥 createWallet: 😎 hooking up with Stellar to generate new keys  💥 💥 💥");
    const keyPair = StellarSdk.Keypair.random();
    const secret = keyPair.secret();
    const accountID = keyPair.publicKey();
    console.log("💥 💥 💥 new wallet public key: " + accountID + ' - ' + secret);
    let server;
    const encrypted = await MyCrypto.encrypt(accountID, secret);
    const wallet = {
      stellarPublicKey: accountID,
      participantId: participantId,
      encryptedSecret: encrypted,
      date: new Date().toISOString(),
      success: false,
      dateRegistered: new Date().toISOString(),
      secret: secret,
      balance: STARTING_BALANCE,
      docType: 'com.oneconnect.biz.Wallet'
    };

    if (debug === true) {
      return await prepareDebugWallet();
    } else {
      return await prepareRealWallet();
    }

    async function prepareDebugWallet() {
      console.log(
        "prepareDebugAccount: - creating DEBUG account and begging for dev XLM ########"
      );
      await requestor.get(
        {
          url: "https://friendbot.stellar.org",
          qs: { addr: accountID },
          json: true
        },
        async function (error, mResponse, body) {
          console.log("friendbot: response statusCode: " + mResponse.statusCode);
          if (error) {
            throw error;
          }
          if (mResponse.statusCode === 200) {
            console.log(
              "\n💙  💚  💛  SUCCESS!!! ### test wallet has 10,000 XLM on Stellar. 💙  💚  💛\n"
            );
            wallet.success = true;
            wallet.balance = '10000.00';

            const bw: any = await putOnBlockchainAndFirestore();
            wallet.docType = bw.docType;
            await sendToTopic("walletsCreated");
            console.log(`\n☕️ ☕️ ☕️  debug Stellar wallet created, key: ${wallet.stellarPublicKey} Lumens: ${wallet.balance} ☕️ ☕️ ☕️\n`);
            return wallet;
          } else {
            const msg =
              "wallet failed, response code from Stellar: " +
              mResponse.statusCode;
            console.log(msg);
            throw new Error(msg);
          }
        }
      );
    }
    async function prepareRealWallet() {
      try {
        console.log("🤕  🤕  🤕   sourceSeed: " + sourceSeed);
        const sourceKeypair = StellarSdk.Keypair.fromSecret(sourceSeed);
        const sourcePublicKey = sourceKeypair.publicKey();
        console.log("🤕  🤕  🤕  sourcePublicKey: " + sourcePublicKey);

        server = new StellarSdk.Server("https://horizon.stellar.org/");
        StellarSdk.Network.usePublicNetwork();

        const account = await server.loadAccount(sourcePublicKey);
        const transaction = new StellarSdk.TransactionBuilder(account)
          .addOperation(
            StellarSdk.Operation.createAccount({
              destination: accountID,
              startingBalance: STARTING_BALANCE
            })
          )
          .build();

        console.log("🤕  🤕  🤕  about to sign and submit stellar transaction ...");
        transaction.sign(sourceKeypair);
        const transactionResult = await server.submitTransaction(transaction);
        console.log(
          "\n☕️ ☕️ ☕️ transactionResult: \n" +
          JSON.stringify(
            StellarSdk.xdr.TransactionResult.fromXDR(
              transactionResult.result_xdr,
              "base64"
            )
          )
        );

        if (transactionResult.statusCode === 200) {
          console.log(
            "💙  💚  💛   Major SUCCESS!!!! Account created on Stellar Blockchain Network. will write wallet to Firestore"
          );
          wallet.success = true;
          wallet.balance = STARTING_BALANCE;
          const bw: any = await putOnBlockchainAndFirestore();
          wallet.docType = bw.docType;

          await sendToTopic("walletsCreated");
          console.log(`☕️ ☕️ ☕️  Stellar wallet created, key: ${wallet.stellarPublicKey}  Lumens: ${wallet.balance}  ☕️ ☕️ ☕️ `);
          return wallet;
        } else {
          const msg =
            "👿 👿 👿 wallet failed, response code from Stellar: " +
            transactionResult.statusCode
          console.log(msg);
          throw new Error(msg);
        }
      } catch (error) {
        //something went boom!
        console.error(error);
        throw error;
      }
    }

    async function putOnBlockchainAndFirestore() {
      const payload: any = await TransactionService.send(Constants.DEFAULT_USERNAME, Constants.CHAIN_ADD_STELLAR_WALLET, JSON.stringify(wallet));
      console.log(`\n☕️ ☕️ ☕️ BFN chaincode ${Constants.CHAIN_ADD_STELLAR_WALLET} processed; payload: \n ${JSON.stringify(payload)} \nend of payload ☕️ ☕️ ☕️ `);
      if (payload.statusCode === 200) {
        const ref = await firestore.collection(Constants.FS_WALLETS).doc(participantId).set(payload.result);
        console.log(`\n💦  💦  wallet key: ${wallet.stellarPublicKey} for participantId: ${participantId} written to Firestore at ${ref.writeTime.toDate()}`);
      } else {
        console.error(`\n👿 👿 👿 Failed to write wallet to BFN: ${payload.message}`);
      }
      return payload;
    }
    async function sendToTopic(topic: string) {
      let msg = "☕️ ☕️ ☕️  A BFN Wallet created. Public Key: " + accountID;
      if (topic === "walletsFailed") {
        msg = "Wallet creation failed";
      }
      const payload = {
        data: {
          messageType: "WALLET",
          json: JSON.stringify(wallet)
        },
        notification: {
          title: "BFN Wallet",
          body: msg
        }
      };
      console.log(
        "💦  💦  sending wallet message to topic: " + wallet.stellarPublicKey
      );
      return await admin.messaging().sendToTopic(topic, payload);
    }
  }
}
