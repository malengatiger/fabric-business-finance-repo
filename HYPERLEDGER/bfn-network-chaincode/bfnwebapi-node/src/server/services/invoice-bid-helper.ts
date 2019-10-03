import { FirestoreService } from './firestore-service';
import * as admin from "firebase-admin";
import { CloseHelper } from "./close-helper";
import { TransactionService } from './transaction-service';
import { Constants } from '../models/constants';
import * as fs from 'fs';
import { Contract } from 'fabric-network';

export class InvoiceBidHelper {
  public static async writeInvoiceBid(invoiceBid: any, contract: Contract): Promise<any> {
    console.log(
      `\n😡 😡 😡 😡 InvoiceBidHelper: 🥦 checking bid totals before sending bid to BFN: offerId: 😡 ${invoiceBid.offer}.... 😡 😡 😡 😡 `
    );

    const offerId = invoiceBid.offer;
    try {
      //final check before bid is made:
      const proceed: boolean = await checkTotalBids();
      if (proceed === false) {
        const msg = `\n🍷🍷🍷🍷 This offer is already fully bid at 🍷 100.0%  offerId: 😡 ${offerId} 😡 😡 😡 😡`;
        throw new Error(`😈 😈 😈  ERROR: ${msg}`);
      }
      console.log(`🥦 InvoiceBidHelper: submit chaincode transaction to BFN  🌀 🌀 🌀 🌀 ... ${Constants.CHAIN_ADD_INVOICE_BID} 🌀 🌀 🌀 🌀`);
      const mresponse: any = await TransactionService.submit(contract, Constants.CHAIN_ADD_INVOICE_BID, JSON.stringify(invoiceBid), 0);
      console.log(`💚 💚 💚  InvoiceBidHelper: TransactionService.send has returned from BFN, 🥦🥦🥦 status: 💕 💕 ${mresponse.statusCode} 💕 💕`);
      if (mresponse.statusCode === 200) {
        await FirestoreService.writeInvoiceBid(JSON.stringify(mresponse.result));
        if (mresponse.result.reservePercent === 100.0) {
          await FirestoreService.closeOffer(JSON.stringify(mresponse.result));
        }

      }
      return mresponse;
    } catch (error) {
      console.log(`InvoiceBidHelper: writeInvoiceBid error 😈 😈 😈 ${error}`)
      throw error;
    }

    async function checkTotalBids(): Promise<boolean> {
      // console.log(
      //   `\n😡 😡 checkTotalBids ......... offerId: ${offerId}`
      // );
      const start = new Date().getTime();
      let total: number = 0.0;
      let proceed: boolean = false;
      try {
        const msnapshot = await admin
          .firestore()
          .collection("invoiceBids")
          .where("offer", "==", offerId)
          .get();
        msnapshot.forEach(doc => {
          const reservePercent = doc.data()["reservePercent"];
          const mReserve = parseFloat(reservePercent);
          total += mReserve;
        });
        const end1 = new Date().getTime();
        console.log(
          `💦 💦 💦  Queried invoiceBids for offer ${offerId} - ⌛️ ${end1 -
          start} milliseconds elapsed. 🥒 bids found: ${msnapshot.docs.length} 🥒 `
        );

        if (total >= 100.0) {
          console.log(`\n🔵 🔵 🔵  closing offer, reservePercent == 😡 😡 ${total} %`);
          await CloseHelper.writeCloseOfferToBFN(offerId, invoiceBid.supplier, invoiceBid.invoice, contract);
          proceed = false;
        } else {
          proceed = true;
        }
        return proceed;
      } catch (e) {
        console.log("InvoiceBidHelper: checkTotalBids: 😈 😈 😈 -- PROBLEM -- ");
        console.error(e);
        throw e;
      }
    }
  }
}
