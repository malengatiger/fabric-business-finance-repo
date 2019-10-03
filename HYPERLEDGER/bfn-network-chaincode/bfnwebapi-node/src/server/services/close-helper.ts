import * as admin from "firebase-admin";
import { TransactionService } from './transaction-service';
import { Constants } from '../models/constants';
import { Contract } from 'fabric-network';

export class CloseHelper {
  static async writeCloseOfferToBFN(offerId: string, supplier: string, invoice: string, contract: Contract) {

    console.log(`❇️  ❇️  ❇️  ❇️  ❇️  CloseHelper: writeCloseOfferToBFN: offerId: 😎 ${offerId} 🥒 supplier: ${supplier} 🥒 invoice: ${invoice}`)
    try {
      const mjson = {
        offerId: offerId,
        invoice: invoice,
        supplier: supplier,

      }
      console.log(`.... sending closeOffer to BFN (TransactionService.submit): 😎 😎 😎 ${JSON.stringify(mjson)}`)
      const mresponse: any = await TransactionService.submit(contract,
        Constants.CHAIN_CLOSE_OFFER, JSON.stringify(mjson), 0);
      console.log(`🍅 🍅 🍅 response from blockchain: 🥒 🥒 🥒 🥒 🥒 🥒 `)
      console.log(mresponse)
      if (mresponse.statusCode === 200) {
        console.log(`response status: 🍅 🍅 🍅 200 from blockchain, will update Offer on Firestore ...`)
        const res = await updateCloseOfferToFirestore();
        return mresponse;
      } else {
        console.log(
          `😈 😈 😈 BFN ERROR ########### mresponse.status:  😡 ${mresponse.statusCode}  😡  😈 😈 😈`
        );
        throw new Error(
          `BFN error  status: ${mresponse.status} ${mresponse.body}`
        );
      }
    } catch (error) {
      console.log('😈 😈 😈 CloseHelper: Close Offer failed to update Firestore 😈 😈 😈');
      console.log(error);
      throw error;
    }
    async function updateCloseOfferToFirestore() {
      console.log(
        `❄️ CloseHelper: updateCloseOfferToFirestore: ❄️ ❄️ ❄️ close Offer: 😡 ${offerId} `
      );

      try {
        const snapshot = await admin
          .firestore()
          .collection(Constants.FS_OFFERS)
          .doc(offerId)
          .get();

        if (snapshot.data()) {
          console.log(`🍊 CloseHelper: Offer found for closing: ☕️  ☕️  ☕️ 🍊 ${snapshot.data()} 🍊`)
        }
        let mData: any = snapshot.data();
        mData.isOpen = false;
        mData.dateClosed = new Date().toISOString();
        await snapshot.ref.set(mData);
        console.log(
          `🍷 offer closed ,  ❄️ ❄️ ❄️ isOpen set to false - 🍷🍷 updated on Firestore`
        );

        console.log(
          `********************* offer data on Firestore: 😎 😎 😎 ${JSON.stringify(mData)} 😎 😎 😎\n`
        );
        return 0;
      } catch (e) {
        console.log("😈 😈 😈 ERROR, probably JSON data format related: 😈 😈 😈");
        console.log(e);
        throw e;
      }
    }
  }
}
