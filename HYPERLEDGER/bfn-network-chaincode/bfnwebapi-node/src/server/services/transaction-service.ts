import { FileSystemWallet, Contract, Transaction } from "fabric-network";
import { ConnectToChaincode } from "./connection";
import { WalletHelper } from "./wallet-helper";
import { Constants } from "../models/constants";
import { FirestoreService } from "./firestore-service";
import { StellarWalletService } from './stellar-service';
const z = "\n\n";

export class TransactionService {
  public static async send(
    userName: string,
    functioName: string,
    jsonString: string
  ): Promise<any> {
    let start1 = new Date().getTime();
    const mResults: any[] = [];
    try {
      //todo - user wallet to be used here
      const wallet: FileSystemWallet = await WalletHelper.getAdminWallet();
      const contract: Contract = await ConnectToChaincode.getContract(
        userName,
        wallet
      );
      const list: any[] = JSON.parse(jsonString);
      let index = 0;
      if (Object.prototype.toString.call(list) === '[object Array]') {
        console.log(`▶️ ▶️ ▶️ Process a list of transactions ... length: 💙❤️ ${list.length} ▶️ ▶️ ▶️ `);
        for (const m of list) {
          const resp: any = await this.submit(contract, functioName, JSON.stringify(m), index);
          index++;
          mResults.push(resp.result);
        }
        const m = `🍓 🍓 🍓 ${mResults.length} transactions of 🔆🔆 ${functioName} processed  🍓 🍓 🍓`;
        console.log(m);
        return {
          message: m,
          result: mResults,
          statusCode: 200
        }

      } else {
        console.log(`▶️ ▶️ ▶️ Process just 1 transaction ...`);
        const resp: any = await this.submit(contract, functioName, jsonString, 0);
        return {
          message: `🥦 🥦 🥦 ${functioName} processed  🥦 🥦 🥦`,
          result: resp.result,
          statusCode: 200
        }
      }
    } catch (e) {
      const msg = `👿 👿 👿 Error processing transaction, throwing my toys 👿 👿 👿${z}${e}${z}`;
      console.log(msg);
      throw new Error(msg);
    }
  }

  public static async submit(contract: Contract, functionName: string, jsonString: string, index: number) {
    console.log(`\n\n🍀 🍀 🍀 🍀  submitting transaction to BFN ... 💦 index: ${index}, 💦 functionName: ${functionName} ....`);
    const transaction: Transaction = contract.createTransaction(functionName);
    const start1 = new Date().getTime();
    let payload: Buffer;

    if (functionName.startsWith("get")) {
      if (jsonString) {
        payload = await transaction.evaluate(jsonString);
      } else {
        payload = await transaction.evaluate();
      }
    } else {
      if (jsonString) {
        payload = await transaction.submit(jsonString);
      } else {
        payload = await transaction.submit();
      }
    }
    const end = new Date().getTime();
    const elapsed4 = (end - start1) / 1000
    const response: any = JSON.parse(payload.toString());
    console.log(`☕️  ☕️  ☕️  PAYLOAD! status code: 😡 ${response.statusCode} 😡 ${response.message} ☕️  ☕️  ☕️  transaction: 😡 ${functionName}`);
    console.log(`⌛️❤️ BFN Contract execution took ❤️ ${elapsed4} seconds\n`);

    if (response.statusCode === 200) {
      await this.writeToFirestore(functionName, JSON.stringify(response.result));
      const end = new Date().getTime();
      const elapsed4 = (end - start1) / 1000
      console.log(`⌛️❤️  Contract Execution + Firestore Write:  ❤️  took ${elapsed4} seconds:  😎 😎 😎\n\n`);
    } else {
      console.log(`👿 👿 👿  contract execution fucked up in ${elapsed4} seconds: 👿 👿 👿 ${response.message}\n\n`)
    }
    return response;
  }
  private static async writeToFirestore(functioName: string, payload: string) {
    const start = new Date().getTime();
    switch (functioName) {
      case Constants.CHAIN_ADD_COUNTRY:
        await FirestoreService.writeCountry(payload);
        break;
      case Constants.CHAIN_ADD_USER:
        await FirestoreService.writeUser(payload);
        break;
      case Constants.CHAIN_ADD_SECTOR:
        await FirestoreService.writeSector(payload);
        break;
      case Constants.CHAIN_ADD_CUSTOMER:
        await StellarWalletService.createWallet(JSON.parse(payload).participantId);
        await FirestoreService.writeCustomer(payload);
        break;
      case Constants.CHAIN_ADD_SUPPLIER:
        await StellarWalletService.createWallet(JSON.parse(payload).participantId);
        await FirestoreService.writeSupplier(payload);
        break;
      case Constants.CHAIN_ADD_INVESTOR:
        await StellarWalletService.createWallet(JSON.parse(payload).participantId);
        await FirestoreService.writeInvestor(payload);
        break;
      case Constants.CHAIN_ADD_PURCHASE_ORDER:
        await FirestoreService.writePurchaseOrder(payload);
        break;
      case Constants.CHAIN_ADD_DELIVERY_NOTE:
        await FirestoreService.writeDeliveryNote(payload);
        break;
      case Constants.CHAIN_ADD_DELIVERY_NOTE_ACCEPTANCE:
        await FirestoreService.writeDeliveryAcceptance(payload);
        break;
      case Constants.CHAIN_ADD_INVOICE:
        await FirestoreService.writeInvoice(payload);
        break;
      case Constants.CHAIN_ADD_INVOICE_ACCEPTANCE:
        await FirestoreService.writeInvoiceAcceptance(payload);
        break;
      case Constants.CHAIN_ADD_OFFER:
        await FirestoreService.writeOffer(payload);
        break;
      case Constants.CHAIN_ADD_INVOICE_BID:
        await FirestoreService.writeInvoiceBid(payload);
        break;
      case Constants.CHAIN_ADD_INVESTOR_PROFILE:
        await FirestoreService.writeInvestorProfile(payload);
        break;
      case Constants.CHAIN_ADD_AUTOTRADE_ORDER:
        await FirestoreService.writeAutoTradeOrder(payload);
        break;
      case Constants.CHAIN_ADD_AUTOTRADE_START:
        await FirestoreService.writeAutoTradeStart(payload);
        break;
      case Constants.CHAIN_CLOSE_OFFER:
        await FirestoreService.closeOffer(payload);
        break;
    }
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000
    console.log(`⌛️ 🔵 🔵 🔵  writeToFirestore: Firestore ${functioName}; write took  🔵 ${elapsed4} seconds  🔵 🔵 🔵`)

  }
}
