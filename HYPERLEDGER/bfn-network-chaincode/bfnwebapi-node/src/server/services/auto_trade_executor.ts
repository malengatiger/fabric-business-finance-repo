import { FirestoreService } from './firestore-service';
// ###########################################################################
// Execute Auto Trading Session - investors matched with offers and bids made
// ###########################################################################

import * as admin from "firebase-admin";
import * as Matcher from "./matcher";
import { AutoTradeOrder } from "../models/auto-trade-order";
import { InvestorProfile } from "../models/investor-profile";
import { Offer } from "../models/offer";
import { ExecutionUnit } from "../models/execution-unit";
import { InvoiceBidHelper } from './invoice-bid-helper';
import { WalletHelper } from './wallet-helper';
import { Constants } from '../models/constants'
import { ConnectToChaincode } from './connection';
import { Contract, FileSystemWallet } from 'fabric-network';
//curl --header "Content-Type: application/json"   --request POST   --data '{"debug": "true"}'   https://us-central1-business-finance-dev.cloudfunctions.net/executeAutoTrade

export class AutoTradeExecutor {
  //
  public static async executeAutoTrades(): Promise<any> {
    console.log(
      `\n\n\n🔵 🔵 🔵 🔵 🔵 🔵  AutoTradeExecutor: preparing AutoTrade session .... 🔵 🔵 🔵 🔵\n`
    );
    let orders: AutoTradeOrder[] = [];
    let profiles: InvestorProfile[] = [];
    let offers: Offer[] = [];
    let units: ExecutionUnit[] = [];

    //todo - user wallet to be used here
    const wallet: FileSystemWallet = await WalletHelper.getAdminWallet();
    const contract: Contract = await ConnectToChaincode.getContract(
      Constants.DEFAULT_USERNAME,
      wallet
    );

    const autoTradeStart = {
      totalValidBids: 0,
      totalOffers: 0,
      possibleAmount: 0.0,
      totalAmount: 0.0,
      dateStarted: new Date().toISOString(),
      dateEnded: new Date().toISOString()
    };
    const startKey = `start-${new Date().getTime()}`;
    const startTime = new Date().getTime();
    let invoiceBidCount = 0;
    const fs = admin.firestore();
    try {
      const firestore = admin.firestore();
      const settings = { /* your settings... */ timestampsInSnapshots: true };
      firestore.settings(settings);
    } catch (e) { }
    //
    await sendMessageToHeartbeatTopic(
      `🙄 🙄 🙄 AutoTrade Session starting on: ❤️ ❤️ ${new Date().toISOString()}`
    );

    await startAutoTradeSession();
    return autoTradeStart;

    async function startAutoTradeSession() {
      const date = new Date().toISOString();
      console.log(`🙄 🙄 🙄 🙄 🙄 🙄 starting AutoTrade Session ########### ❤️ ❤️ ${date} ..... `);
      await writeAutoTradeStart();
      const result = await getData();
      if (result > 0) {
        await buildUnits();
        units.map(unit => {
          autoTradeStart.possibleAmount += unit.offer.offerAmount;
        });
        await sendMessageToHeartbeatTopic(
          `🙄 🙄 🙄  Prepare bids for BFN, executionUnits: ${units.length}`
        );
        await writeBids();
      }
      console.log(`💦 💦 💦 💦  autoTradeStart: ${JSON.stringify(autoTradeStart)}`);
      return await finishAutoTrades();
    }
    async function finishAutoTrades() {
      const now: number = new Date().getTime();
      const elapsed = (now - startTime) / 1000;
      await updateAutoTradeStart();
      console.log(`\n\n💙 💚 💛 ❤️ 💜  Auto Trading Session completed; autoTradeStart updated.  🛂 Done in: ${elapsed} seconds.\n\n💋 💋 💋 We are DONE and DUSTED, Houston!! 💋 💋 💋\n\n\n`);
      await sendMessageToHeartbeatTopic(
        `💙 💚  💛 ❤️ 💜 AutoTrade Session complete, elapsed: ${
        elapsed
        } seconds`
      );
      return null
    }
    async function writeBids() {
      for (const unit of units) {
        await writeBidToBFN(unit);
        invoiceBidCount++;
        console.log(`\n💦 💦 💦 💦 Invoice Bid #${invoiceBidCount} = ❤️ ${unit.offer.offerId} - ${unit.offer.offerAmount} has been processed`)
      }
      console.log(
        `\n\n🤡 🤡 🤡 writeBids complete. ...closing up! ❤️ ❤️ ❤️ ❤️ ################ bids added: 🎁 ${invoiceBidCount}`
      );
      return null;
    }
    async function writeBidToBFN(unit: ExecutionUnit) {

      try {
        //get existing invoice bids for this offer
        const bidQuerySnap = await fs
          .collection("invoiceBids")
          .where('offer', '==', unit.offer.offerId)
          .get();

        let reserveTotal = 0.0;
        bidQuerySnap.docs.forEach(doc => {
          reserveTotal += doc.data()["reservePercent"];
        });
        if (reserveTotal > 0) {
          console.log(
            `\n🤢 🤢 🤢 total percent reserved: ${reserveTotal} % from ${
            bidQuerySnap.size
            } existing bids. Offer amt: ${unit.offer.offerAmount}`
          );
        }
        const myReserve = 100.0 - reserveTotal;
        const myAmount = unit.offer.offerAmount * (myReserve / 100);
        const ONE_HOUR = 1000 * 60 * 60;
        const ONE_DAY = ONE_HOUR * 24;
        const ONE_WEEK_FROM_NOW = new Date().getTime() + ONE_DAY * 14;
        const mdate = new Date(ONE_WEEK_FROM_NOW);

        if (!unit.offer.customer) {
          throw new Error("👿  👿  👿  👿  Customer is null: .... wtf?");
        }
        const bid = {
          // invoiceBidId: uuid(),
          amount: myAmount,
          reservePercent: myReserve,
          autoTradeOrder: unit.order.autoTradeOrderId,
          investor: unit.order.investor,
          offer: unit.offer.offerId,
          invoice: unit.offer.invoice,
          investorName: unit.order.investorName,
          wallet: unit.order.wallet,
          date: new Date().toISOString(),
          intDate: null,
          isSettled: false,
          supplier: unit.offer.supplier,
          supplierName: unit.offer.supplierName,
          customerName: unit.offer.customerName,
          customer: unit.offer.customer,
          discountPercent: unit.offer.discountPercent,
          startTime: new Date().toISOString(),
          endTime: mdate.toISOString()
        };
        // console.log(unit.offer);
        // console.log(`\n😎 😎 😎 ++++ bid to be written to BFN: 🤢 🤢 🤢 \n${JSON.stringify(bid)} 😎 😎 😎\n`);
        try {
          await InvoiceBidHelper.writeInvoiceBid(bid, contract);
          autoTradeStart.totalAmount += myAmount;
          autoTradeStart.totalValidBids++;
        } catch (e) {
          console.log(`AutoTradeExecutor: 😈 😈 😈 bid write failed: \n${e}`);
        }
        return null;
      } catch (e) {
        throw new Error(JSON.stringify({
          message: `😈 😈 😈 InvoiceBid write failed  😈 😈 😈`,
          error: e
        }));
      }
    }
    async function getData() {
      console.log("\n💦 💦 💦 💦 💦 ################### getData  🛂  🛂  🛂  🛂 \n");
      await sendMessageToHeartbeatTopic("💦 Collecting auto trade base data");
      let qso;
      const endDate = new Date().toISOString();
      console.log(` 😎 😎 checking that endTime on DB greater than ${endDate}`)
      qso = await fs
        .collection(Constants.FS_OFFERS)
        .where("isOpen", "==", true)
        .where("endTime", ">", endDate)
        .orderBy("endTime")
        .get()
        .catch(e => {
          console.log(e);
          throw e;
        });
      console.log(`💦 💦  ###### open offers found:  🛂 ${qso.docs.length}  🛂 `);
      autoTradeStart.totalOffers = qso.docs.length;
      offers = [];
      qso.docs.forEach(doc => {
        const data = doc.data();
        const offer: Offer = new Offer();
        offer.offerId = data["offerId"];
        offer.isOpen = data["isOpen"];
        offer.isCancelled = data["isCancelled"];
        offer.offerAmount = data["offerAmount"];
        offer.discountPercent = data["discountPercent"];
        offer.startTime = data["startTime"];
        offer.endTime = data["endTime"];
        offer.invoice = data["invoice"];
        offer.date = data["date"];
        offer.invoiceAmount = data["invoiceAmount"];
        offer.customerName = data["customerName"];
        offer.supplier = data["supplier"];
        offer.supplierName = data["supplierName"];
        offer.documentReference = data["documentReference"];

        if (!data["customer"]) {
          throw new Error(
            `😈 😈 😈  ERROR - customer is NULL. you have to be kidding! ${
            doc.ref.path
            }`
          );
        }
        offer.customer = data["customer"];
        offers.push(offer);
      });

      if (qso.docs.length === 0) {
        console.log("😈 😈 😈 No open offers found. quitting ...");
        return 0;
      }
      const m = `💜 open offers found:  🛂 ${offers.length}`;
      await sendMessageToHeartbeatTopic(m);
      let qs;
      qs = await fs
        .collection(Constants.FS_AUTOTRADE_ORDERS)
        .where("isCancelled", "==", false)
        .get()
        .catch(e => {
          console.log(e);
          throw e;
        });
      orders = [];
      qs.docs.forEach(doc => {
        const data = doc.data();
        const order: AutoTradeOrder = new AutoTradeOrder();
        order.autoTradeOrderId = data["autoTradeOrderId"];
        order.date = data["date"];
        order.investor = data["investor"];
        order.investorName = data["investorName"];
        order.wallet = data["wallet"];
        order.isCancelled = data["isCancelled"];
        order.investorProfile = data["investorProfile"];
        order.user = data["user"];
        // console.log(JSON.stringify(data))
        // const orderx: Data.AutoTradeOrder = jsonConvert.deserializeObject(data, Data.AutoTradeStart);
        orders.push(order);
      });
      const m0 = `💜 autoTradeOrders found: ${orders.length}`;
      console.log(m0);
      await sendMessageToHeartbeatTopic(m0);
      shuffleOrders();
      let qsp;
      qsp = await fs
        .collection(Constants.FS_INVESTOR_PROFILES)
        .get()
        .catch(e => {
          console.log(e);
          throw e;
        });
      profiles = [];
      qsp.docs.forEach(doc => {
        const data = doc.data();
        const profile: InvestorProfile = new InvestorProfile();
        profile.profileId = data["profileId"];
        profile.name = data["name"];
        profile.investor = data["investor"];
        profile.maxInvestableAmount = data["maxInvestableAmount"];
        profile.maxInvoiceAmount = data["maxInvoiceAmount"];
        profile.minimumDiscount = data["minimumDiscount"];
        profile.sectors = data["sectors"];
        profile.suppliers = data["suppliers"];
        profile.investorDocRef = data["investorDocRef"];
        profiles.push(profile);
        console.log(
          `###### profile for: 🥦 ${profile.name} 💛 minimumDiscount: ${
          profile.minimumDiscount
          } 💙 maxInvestableAmount: ${
          profile.maxInvestableAmount
          } 💚 maxInvoiceAmount: ${profile.maxInvoiceAmount} `
        );

      });
      const m1 = `💜 investorProfiles found: ${profiles.length}`;
      await sendMessageToHeartbeatTopic(m1);

      console.log(`\n\n❤️ ❤️ ❤️ Profiles and Constraints ❤️ ❤️ ❤️\n`);
      profiles.forEach((p) => {
        console.log(`❤️ minimumDiscount: ${p.minimumDiscount}%  🎁 maxInvoiceAmount: ${p.maxInvoiceAmount} \t💜 maxInvestableAmount: ${p.maxInvestableAmount}\t🥦 ${p.name}`)
      })
      const m2 = `\n💜 Completed data collection, about to build valid execution units`;
      await sendMessageToHeartbeatTopic(m2);
      console.log(m1);
      console.log(m2);
      return offers.length;
    }
    async function buildUnits() {
      console.log(`\n 💊 💊 💊  buildUnits: open offers: ❤️ ${offers.length} - profiles: 💙 ${profiles.length} - orders: 💚${orders.length} `);
      try {
        units = await Matcher.Matcher.match(profiles, orders, offers);
      } catch (e) {
        console.log(e);
        throw new Error(`Matching fell down. ${e}`);
      }
      await sendMessageToHeartbeatTopic(
        `💙 💚 💛  Matcher has created ${units.length} execution units. Ready to rumble!`
      );
      console.log(
        `\n💙 💚 💛  +++ ExecutionUnits ready for processing, execution units: ❤️ ${
        units.length
        }, offers : ❤️ ${offers.length}`
      );
      if (units.length === 0 && offers.length > 0) {
        console.log(`\n\n\n0️⃣ 0️⃣ 0️⃣ 0️⃣ AutoTrade Algorithm could not match 💦 ${offers.length} 💦 offers with any investor profiles. Will QUIT. \n\n\n`);
        var sortedByAmount: Offer[] = offers.sort((obj1, obj2) => {
          if (obj1.offerAmount > obj2.offerAmount) {
            return 1;
          }

          if (obj1.offerAmount < obj2.offerAmount) {
            return -1;
          }

          return 0;
        });
        let cnt = 0;
        console.log('🎁 🎁 🎁  Sorted by Offer Amount');
        sortedByAmount.forEach((o) => {
          cnt++;
          console.log(`0️⃣ 0️⃣ 0️⃣ #${cnt} discountPercent: 🌶 ${o.discountPercent.toFixed(2)} % 🌶  - offerAmount: 🎁 ${o.offerAmount.toFixed(2)} - \t🥦 supplier: ${o.supplierName} 💛 customer: ${o.customerName}`);
        });
        //
        var sortedByDiscount: Offer[] = offers.sort((obj1, obj2) => {
          if (obj1.discountPercent > obj2.discountPercent) {
            return 1;
          }

          if (obj1.discountPercent < obj2.discountPercent) {
            return -1;
          }

          return 0;
        });
        console.log('🌶 🌶 🌶 Sorted by Discount Percentage');
        cnt = 0;
        sortedByDiscount.forEach((o) => {
          cnt++;
          console.log(`0️⃣ 0️⃣ 0️⃣ #${cnt} discountPercent: 🌶 ${o.discountPercent.toFixed(2)} % 🌶  - offerAmount: 🎁 ${o.offerAmount.toFixed(2)} - \t🥦 supplier: ${o.supplierName} 💛 customer: ${o.customerName}`);
        });
        //
        cnt = 0;
        offers.sort((a, b) => `${a.supplierName}`.localeCompare(`${b.supplierName}`))
        console.log('🥦 🥦 🥦 Sorted by Supplier Name');
        offers.forEach((o) => {
          cnt++;
          console.log(`0️⃣ 0️⃣ 0️⃣ #${cnt} discountPercent: 🌶 ${o.discountPercent.toFixed(2)} % 🌶  - offerAmount: 🎁 ${o.offerAmount.toFixed(2)} - \t🥦 supplier: ${o.supplierName} 💛 customer: ${o.customerName}`);
        });

        console.log(`\n\n❤️ ❤️ ❤️ Profiles and Constraints ❤️ ❤️ ❤️\n`);
        cnt = 0;
        profiles.forEach((p) => {
          cnt++;
          console.log(`❤️ #${cnt} minimumDiscount: ${p.minimumDiscount.toFixed(2)}%  🎁 maxInvoiceAmount: ${p.maxInvoiceAmount.toFixed(2)} \t💜 maxInvestableAmount: ${p.maxInvestableAmount.toFixed(2)}\t🥦 ${p.name}`)
        })

        console.log(`\n\n🌶🌶🌶🌶🌶🌶 write ${offers.length} failed offers to Firestore: `);
        for (const offer of offers) {
          await FirestoreService.writeFailedOffer(JSON.stringify(offer));
        }
      }
      return units;
    }
    function shuffleOrders() {
      console.log(orders);
      for (let i = orders.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [orders[i], orders[j]] = [orders[j], orders[i]];
      }
      console.log(
        "\n🙈 🙈 🙈 shuffled orders ........💦 💦 check orders logs ..."
      );
      console.log(orders);
    }
    async function writeAutoTradeStart() {
      await fs
        .collection(Constants.FS_AUTOTRADE_STARTS)
        .doc(startKey)
        .set(autoTradeStart)
        .catch(e => {
          console.error(e);
          throw e;
        });
      console.log(
        `\n\n☕️  ☕️  ☕️  autoTradeStart written to Firestore startKey: ${startKey}`
      );
      return 0;
    }
    async function updateAutoTradeStart() {
      autoTradeStart.dateEnded = new Date().toISOString();
      let t = 0.0;
      units.forEach(u => {
        t += u.offer.offerAmount;
      });
      autoTradeStart.totalAmount = t;
      let mf;
      mf = await fs
        .collection(Constants.FS_AUTOTRADE_STARTS)
        .doc(startKey)
        .set(autoTradeStart)
        .catch(e => {
          console.log(e);
          throw e;
        });
      console.log(
        `\n☕️  ☕️  ☕️ updated AutoTradeStart ###################### ☕️  ☕️  ☕️ ${JSON.stringify(autoTradeStart)} ☕️  ☕️  ☕️`
      );
      return mf;
    }
    async function sendMessageToHeartbeatTopic(message: string) {
      const hb = {
        date: new Date().toISOString(),
        message: message
      };
      const mTopic = `heartbeats`;
      const payload = {
        data: {
          messageType: "HEARTBEAT",
          json: JSON.stringify(hb)
        },
        notification: {
          title: "Heartbeat",
          body: "Heartbeat: " + message
        }
      };

      console.log("\n🚀 🚀 🚀 sending heartbeat to topic: 💦 " + mTopic
        + ', message: 🎁 ' + message + ' 🚀 🚀 🚀');
      return await admin.messaging().sendToTopic(mTopic, payload);
    }
  }
}
