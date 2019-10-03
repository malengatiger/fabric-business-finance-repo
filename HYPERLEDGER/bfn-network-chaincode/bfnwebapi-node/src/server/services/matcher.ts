import { InvestorProfile } from '../models/investor-profile';
import { AutoTradeOrder } from '../models/auto-trade-order';
import { Offer } from '../models/offer';
import { ExecutionUnit } from '../models/execution-unit';
import { InvalidSummary } from '../models/invalid-summary';
import { firestore } from 'firebase-admin';
import * as admin from "firebase-admin";



export class Matcher {
  public static async match(
    profiles: InvestorProfile[],
    orders: AutoTradeOrder[],
    offers: Offer[],
  ) {
    console.info('\n\n🏓 🏓  ## Matcher : 🏓 🏓 start matching ............ 🙄 ');
    const units: ExecutionUnit[] = [];
    let pOffers: Offer[] = offers;
    const failedMap: Map<String, Object> = new Map<String, Object>();

    let loopCount = 0;
    const MAX_LOOPS: number = 10;
    const MAX_UNITS: number = 10;
    console.info(`🏓 🏓  ## Matcher : 🏓 🏓 MAX_LOOPS: ${MAX_LOOPS} 🙄  MAX_UNITS: ${MAX_UNITS}`);
    const invalids = {
      invalidDiscounts: 0,
      invalidOfferAmounts: 0,
      maxUnits: MAX_UNITS,
      maxLoops: MAX_LOOPS,
      autoTradeOrders: orders.length,
      openOffers: pOffers.length,
      date: new Date().toISOString()
    }

    const invalidSummary: InvalidSummary = new InvalidSummary();
    invalidSummary.date = new Date().toISOString();
    let start: number;
    let end: number;
    let orderIndex: number = 0;
    let offerIndex: number = 0;

    console.info('🙄  getting each profiles total existing bids ...');
    for (const prof of profiles) {
      await getInvestorBidTotal(prof);
    }
    shuffleOrders();
    await initializeLoop();
    console.info(
      '🔵 🔵 🔵 🔵 🔵 🔵  initializeLoop: Returning execution units to caller, units:🔵 🏓🏓 ' +
      units.length,
    );
    return units;

    async function initializeLoop() {
      console.info(
        '💦 💦 initializeLoop: loopCount:  🥦 ' +
        loopCount +
        ', ... units: 🏓 ' +
        units.length +
        ', ... offers outstanding: 💙 ' +
        pOffers.length,
      );
      orderIndex = 0;
      offerIndex = 0;
      if (units.length === MAX_UNITS || units.length > MAX_UNITS) {
        return units;
      }

      await control();

      // create new offer list without the offers already taken
      const tempOffers: Offer[] = [];
      for (const off of offers) {
        let isFound = false;
        for (const unit of units) {
          if (off.offerId === unit.offer.offerId) {
            isFound = true;
          }
        }
        if (!isFound) {
          tempOffers.push(off);
        }
      }
      pOffers = tempOffers;
      loopCount++;
      console.info(
        '\n\n🏓 🏓 loop complete, next loop is: 🌀 ' +
        loopCount +
        ' --- MAX_LOOPS:  💦 ' +
        MAX_LOOPS + '\n\n',
      );
      if (loopCount < MAX_LOOPS) {
        shuffleOrders();
        //shuffleOffers();
        await initializeLoop();
      }

      console.log(`\n\n❎ ❎ ❎ 🎁 🎁 🎁  Matcher: 👿 FAILED investor/offer matching  👿 :  ${failedMap.size} attempts failed. 🎁 🎁 🎁 \n\n`);

      // let cnt = 0;
      // failedMap.forEach((obj: any) => {
      //   const o = obj.offer;
      //   const p = obj.profile;
      //   cnt++;
      //   console.log(`#${cnt} ❎ discountPercent: 🌶 ${o.discountPercent.toFixed(1)} % 🌶  - offerAmount: 🎁 ${o.offerAmount.toFixed(2)}\t🥦 supplier: ${o.supplierName} 💛 customer: ${o.customerName}`);
      //   console.log(`#${cnt} 🚹 minimumDiscount: 🌶 ${p.minimumDiscount.toFixed(1)} % 🌶  - maxInvoiceAmount: 🎁 ${p.maxInvoiceAmount.toFixed(2)}\t🥦 investor: ${p.name} 💛`);

      // });
      const ref = await admin.firestore().collection('invalidAutoTrades').add(invalids);
      console.log(`\n🌡 🚽 Invalid AutoTrade summary written to Firestore: 🌡 🚽 \n🚧🚧🚧 ${JSON.stringify(invalids)} \n🚧🚧🚧 Firestore record added: 🏓 ${ref.path}`);
      console.info(
        `\n\n💙 💚 💛 💙 💚 💛 Matcher: MATCHING COMPLETE:  🥦🥦🥦 execution units built: ${units.length},  👉 return to AutoTradeExecutor  💙 💚 💛 💙 💚 💛\n\n`,
      );
      console.info(invalidSummary);
      return units;
    }

    async function control() {
      if (units.length === MAX_UNITS || units.length > MAX_UNITS) {
        return null;
      }
      if (offerIndex === pOffers.length) {
        return null;
      }
      if (orderIndex < orders.length) {
        const isValid = await findInvestorMatch(
          pOffers[offerIndex],
          orders[orderIndex],
        );

        if (isValid) {
          orderIndex++;
          offerIndex++;
          await control();
        } else {
          orderIndex++;
          await control();
        }
      } else {
        orderIndex = 0;
        offerIndex++;
        if (offerIndex === pOffers.length) {
          return null;
        }
        await control();
      }
      return null;
    }
    async function findInvestorMatch(mOffer: Offer, mOrder: AutoTradeOrder, ) {

      // console.log(`🔵🔵 finding investor / offer match ... offerId: 🥦 ${mOffer.offerId} name: ${mOrder.investorName}`);
      let profile: InvestorProfile = new InvestorProfile();
      profiles.forEach((p) => {
        if (
          mOrder.investorProfile ===
          p.profileId
        ) {
          profile = p;
        }
      });
      if (profile.profileId === null) {
        console.info(`😡 😡  profile is NULL for ${mOrder.investorName}`);
        return false;
      }
      // console.log(`🔴🔴 discount: ${mOffer.discountPercent} % - offerAmount: ${mOffer.offerAmount} ⚜️ investor: minimumDiscount: 🌶 ${profile.minimumDiscount} %  - maxInvoiceAmount: 🌶 ${profile.maxInvoiceAmount} `);
      start = new Date().getTime();
      const isValidBid: boolean = await validate(profile, mOffer);
      end = new Date().getTime();

      if (isValidBid) {
        const unit = new ExecutionUnit();
        unit.offer = mOffer;
        unit.profile = profile;
        unit.order = mOrder;
        units.push(unit);
        invalidSummary.totalUnits++;
        profile.totalBidAmount += mOffer.offerAmount;
        console.info(
          `🍏🍎 valid execution unit created, units: 🌀 ${units.length}, offerAmount: 🌀 ${mOffer.offerAmount.toFixed(2)} \t💙 added for ${
          unit.profile.name
          } 💙 💙 `,
        );
        return isValidBid;
      } else {
        invalidSummary.invalidTrades++;
      }

      return false;
    }

    async function validate(profile: InvestorProfile, offer: Offer) {
      if (profile === null) {
        return false;
      }
      let isValidTotal = false;
      const isValidSupplier = isWithinSupplierList(profile, offer);
      const isValidSector = isWithinSectorList(profile, offer);
      const isValidAccountBalance = await isAccountBalanceOK(profile);
      let isValidInvoiceAmount = false;
      let isValidMinimumDiscount = false;
      const mTotal = profile.totalBidAmount + offer.offerAmount;
      if (
        mTotal < profile.maxInvestableAmount ||
        mTotal === profile.maxInvestableAmount
      ) {
        isValidTotal = true;
      } else {
        invalidSummary.isValidInvestorMax++;
      }
      if (
        offer.discountPercent > profile.minimumDiscount ||
        offer.discountPercent === profile.minimumDiscount
      ) {
        isValidMinimumDiscount = true;
      } else {
        invalidSummary.isValidMinimumDiscount++;
        invalids.invalidDiscounts++;
      }
      if (
        offer.offerAmount < profile.maxInvoiceAmount ||
        offer.offerAmount === profile.maxInvoiceAmount
      ) {
        isValidInvoiceAmount = true;
      } else {
        invalidSummary.isValidInvoiceAmount++;
        invalids.invalidOfferAmounts++;
      }
      if (
        isValidTotal &&
        isValidSupplier &&
        isValidSector &&
        isValidInvoiceAmount &&
        isValidMinimumDiscount &&
        isValidAccountBalance
      ) {
        return true;
      } else {
        const m = {
          offer: offer,
          profile: profile
        }
        failedMap.set(`${offer.offerId}_${profile.investor}`, m);
        return false;
      }
    }
    async function getInvestorBidTotal(profile: InvestorProfile) {
      //   let querySnap;
      //   querySnap = await admin
      //     .firestore()
      //     .collection("investors")
      //     .where("participantId", "==", profile.investor.split("#")[1])
      //     .get();
      //   if (querySnap.docs.length > 0) {
      //     const investorRef = querySnap.docs[0].ref;
      //     let bidQuerySnap;
      //     bidQuerySnap = await investorRef
      //       .collection("invoiceBids")
      //       .where("isSettled", "==", false)
      //       .get();
      //     if (bidQuerySnap.docs.length === 0) {
      //       return true;
      //     } else {
      //       let total = 0.0;
      //       bidQuerySnap.forEach(doc => {
      //         const bid = doc.data();
      //         total += bid.amount;
      //       });
      //       profile.totalBidAmount = total;
      //     }
      //   }
      //   await sendMessageToHeartbeatTopic(
      //     `completed trade data aggregation for investor existing bids: ${
      //       profile.name
      //     }`
      //   );
      //   console.info(
      //     "Total existing bid amount: " +
      //       profile.totalBidAmount +
      //       " for " +
      //       profile.name
      //   );
      return true;
    }
    function isWithinSupplierList(profile: InvestorProfile, offer: Offer, ) {
      try {
        if (profile === null) {
          return true;
        }
        if (!profile.suppliers) {
          return true;
        }
        if (profile.suppliers.length === 0) {
          return true;
        }
        let isSupplierOK = false;
        profile.suppliers.forEach((supplier) => {
          if (
            offer.supplier ===
            supplier
          ) {
            isSupplierOK = true;
          }
        });
        if (!isSupplierOK) {
          invalidSummary.isValidSupplier++;
        }
        return isSupplierOK;
      } catch (e) {
        console.info(e);
        console.info(
          `FAILED: supplier validation - for ${
          offer.supplierName
          } ${offer.offerAmount}`,
        );
        return true;
      }
    }
    function isWithinSectorList(
      profile: InvestorProfile,
      offer: Offer,
    ) {
      try {
        if (profile === null) {
          return true;
        }
        if (!profile.sectors) {
          return true;
        }
        if (profile.sectors.length === 0) {
          return true;
        }
        let isSectorOK = false;
        profile.sectors.forEach((sector) => {
          if (
            offer.sector ===
            sector
          ) {
            isSectorOK = true;
          }
        });
        if (!isSectorOK) {
          invalidSummary.isValidSector++;
        }
        return isSectorOK;
      } catch (e) {
        console.info(e);
        console.info(
          `FAILED: sector validation for ${
          offer.supplierName
          } ${offer.offerAmount}`,
        );
        return true;
      }
    }
    async function isAccountBalanceOK(profile: InvestorProfile) {
      // TODO - connect to Stellar/WorldWire here
      return true;
    }

    // function shuffleOffers() {
    console.log('\n💦 💦 💦 💦 💦 💦 💦 💦 💦 💦 💦 💦 💦 shuffleOffers ...')
    const m: Offer[] = []

    var a: any[] = [];
    let index = 0;
    offers.forEach((o) => {
      a.push(index);
      index++;
    });
    const indexes: any[] = shuffle(a);
    console.log(indexes);
    index = 0;
    indexes.forEach((i) => {
      m.push(offers[i]);
      index++;
    })
    offers = m;
    console.log(`🏓🏓🏓🏓 shuffled OFFERS ... ${offers.length} ... 🥦`)

    // }
    function shuffleOrders() {
      console.log('\n\n💦 💦 💦 💦 💦 💦 💦 💦 💦 💦 💦 💦 💦 shuffleOrders ...')
      console.log(orders);

      const m: AutoTradeOrder[] = []

      var a: any[] = [];
      let index = 0;
      orders.forEach((o) => {
        a.push(index);
        index++;
      });
      const indexes: any[] = shuffle(a);
      console.log(indexes);
      index = 0;
      indexes.forEach((i) => {
        m.push(orders[i]);
        index++;
      })
      orders = m;
      console.log(`🏓🏓🏓🏓 shuffled orders ... check ... 🥦 order of items`)
      console.log(orders);

    }
    function shuffle(arr: any) {
      var i,
        j,
        temp;
      for (i = arr.length - 1; i > 0; i--) {
        j = Math.floor(Math.random() * (i + 1));
        temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
      }
      return arr;
    };

  }
}
