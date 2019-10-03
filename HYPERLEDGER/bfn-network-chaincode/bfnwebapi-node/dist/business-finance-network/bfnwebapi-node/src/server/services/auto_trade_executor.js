"use strict";
// ###########################################################################
// Execute Auto Trading Session - investors matched with offers and bids made
// ###########################################################################
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const admin = tslib_1.__importStar(require("firebase-admin"));
const Matcher = tslib_1.__importStar(require("./matcher"));
const auto_trade_order_1 = require("../models/auto-trade-order");
const investor_profile_1 = require("../models/investor-profile");
const offer_1 = require("../models/offer");
const invoice_bid_helper_1 = require("./invoice-bid-helper");
const wallet_helper_1 = require("./wallet-helper");
const constants_1 = require("../models/constants");
const connection_1 = require("./connection");
//curl --header "Content-Type: application/json"   --request POST   --data '{"debug": "true"}'   https://us-central1-business-finance-dev.cloudfunctions.net/executeAutoTrade
class AutoTradeExecutor {
    //
    static executeAutoTrades() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`\n\n\n🔵  🔵  🔵  🔵  🔵  🔵  AutoTradeExecutor: preparing AutoTrade session .... 🔵  🔵  🔵  🔵\n`);
            let orders = [];
            let profiles = [];
            let offers = [];
            let units = [];
            //todo - user wallet to be used here
            const wallet = yield wallet_helper_1.WalletHelper.getAdminWallet();
            const contract = yield connection_1.ConnectToChaincode.getContract(constants_1.Constants.DEFAULT_USERNAME, wallet);
            const autoTradeStart = {
                totalValidBids: 0,
                totalOffers: 0,
                totalInvalidBids: 0,
                possibleAmount: 0.0,
                totalAmount: 0.0,
                elapsedSeconds: 0.0,
                closedOffers: 0,
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
            }
            catch (e) { }
            //
            yield sendMessageToHeartbeatTopic(`🙄 🙄 🙄 AutoTrade Session starting on: ${new Date().toISOString()}`);
            yield startAutoTradeSession();
            return autoTradeStart;
            function startAutoTradeSession() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    const date = new Date().toISOString();
                    console.log(`🙄 🙄 🙄 🙄 🙄 🙄 starting AutoTrade Session ########### ${date}`);
                    yield writeAutoTradeStart();
                    const result = yield getData();
                    if (result > 0) {
                        yield buildUnits();
                        units.map(unit => {
                            autoTradeStart.possibleAmount += unit.offer.offerAmount;
                        });
                        yield sendMessageToHeartbeatTopic(`🙄 🙄 🙄  Prepare bids for BFN, executionUnits: ${units.length}`);
                        yield writeBids();
                    }
                    console.log(`💦 💦 💦 💦  autoTradeStart: ${autoTradeStart}`);
                    return yield finishAutoTrades();
                });
            }
            function finishAutoTrades() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    const now = new Date().getTime();
                    const elapsed = (now - startTime) / 1000;
                    autoTradeStart.elapsedSeconds = elapsed;
                    yield updateAutoTradeStart();
                    console.log(`\n\n\n💙  💚  💛  ❤️  💜  Auto Trading Session completed; autoTradeStart updated. Done in 
            ${autoTradeStart.elapsedSeconds} seconds. \n💋 💋 💋 We are HAPPY, Houston!! 💋 💋 💋\n\n\n`);
                    yield sendMessageToHeartbeatTopic(`💙  💚  💛  ❤️  💜 AutoTrade Session complete, elapsed: ${autoTradeStart.elapsedSeconds} seconds`);
                    return null;
                });
            }
            function writeBids() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    for (const unit of units) {
                        yield writeBidToBFN(unit);
                        invoiceBidCount++;
                        console.log(`\n💦 💦 💦 💦 Invoice Bid #${invoiceBidCount} = ${unit.offer.offerId} - ${unit.offer.offerAmount} has been processed`);
                    }
                    console.log(`\n\n🤡 🤡 🤡 writeBids complete. ...closing up! ################`);
                    return null;
                });
            }
            function writeBidToBFN(unit) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.log(`🤢 writeBidToBFN: offer document ref: ${unit.offer.offerId}`);
                    try {
                        //get existing invoice bids for this offer
                        const bidQuerySnap = yield fs
                            .collection("invoiceBids")
                            .where('offer', '==', unit.offer.offerId)
                            .get();
                        let reserveTotal = 0.0;
                        bidQuerySnap.docs.forEach(doc => {
                            reserveTotal += doc.data()["reservePercent"];
                        });
                        if (reserveTotal > 0) {
                            console.log(`\n🤢 🤢 🤢 total percent reserved: ${reserveTotal} % from ${bidQuerySnap.size} existing bids. Offer amt: ${unit.offer.offerAmount}`);
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
                        console.log(unit.offer);
                        console.log(`\n😎 😎 😎 ++++ bid to be written to BFN: 🤢 🤢 🤢 \n${JSON.stringify(bid)} 😎 😎 😎\n`);
                        yield invoice_bid_helper_1.InvoiceBidHelper.writeInvoiceBid(bid, contract);
                        autoTradeStart.totalValidBids++;
                        return null;
                    }
                    catch (e) {
                        throw new Error(JSON.stringify({
                            message: `😈 😈 😈 InvoiceBid write failed  😈 😈 😈`,
                            error: e
                        }));
                    }
                });
            }
            function getData() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.log("\n💦 💦 💦 💦 💦 ################### getData \n");
                    yield sendMessageToHeartbeatTopic("💦 💦 💦 Collecting auto trade base data");
                    let qso;
                    const endDate = new Date().toISOString();
                    console.log(` 😎 😎 checking that endTime on DB greater than ${endDate}`);
                    qso = yield fs
                        .collection(constants_1.Constants.FS_OFFERS)
                        .where("isOpen", "==", true)
                        .where("endTime", ">", endDate)
                        .orderBy("endTime")
                        .get()
                        .catch(e => {
                        console.log(e);
                        throw e;
                    });
                    console.log(`💦 💦  ###### open offers found: ${qso.docs.length}`);
                    autoTradeStart.totalOffers = qso.docs.length;
                    offers = [];
                    qso.docs.forEach(doc => {
                        const data = doc.data();
                        const offer = new offer_1.Offer();
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
                            throw new Error(`😈 😈 😈  ERROR - customer is NULL. you have to be kidding! ${doc.ref.path}`);
                        }
                        offer.customer = data["customer"];
                        offers.push(offer);
                    });
                    if (qso.docs.length === 0) {
                        console.log("😈 😈 😈 No open offers found. quitting ...");
                        return 0;
                    }
                    const m = `💜 💜 💜  open offers found: ${offers.length}`;
                    yield sendMessageToHeartbeatTopic(m);
                    let qs;
                    qs = yield fs
                        .collection(constants_1.Constants.FS_AUTOTRADE_ORDERS)
                        .where("isCancelled", "==", false)
                        .get()
                        .catch(e => {
                        console.log(e);
                        throw e;
                    });
                    orders = [];
                    qs.docs.forEach(doc => {
                        const data = doc.data();
                        const order = new auto_trade_order_1.AutoTradeOrder();
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
                    const m0 = `💜 💜 💜  autoTradeOrders found: ${orders.length}`;
                    console.log(m0);
                    yield sendMessageToHeartbeatTopic(m0);
                    shuffleOrders();
                    let qsp;
                    qsp = yield fs
                        .collection(constants_1.Constants.FS_INVESTOR_PROFILES)
                        .get()
                        .catch(e => {
                        console.log(e);
                        throw e;
                    });
                    profiles = [];
                    qsp.docs.forEach(doc => {
                        const data = doc.data();
                        const profile = new investor_profile_1.InvestorProfile();
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
                        console.log(`###### profile for: ${profile.name} minimumDiscount: ${profile.minimumDiscount} maxInvestableAmount: ${profile.maxInvestableAmount} maxInvoiceAmount: ${profile.maxInvoiceAmount} `);
                        console.log(profile);
                    });
                    const m1 = `💜 💜 💜  investorProfiles found: ${profiles.length}`;
                    yield sendMessageToHeartbeatTopic(m1);
                    const m2 = `💜 💜 💜  Completed data collection, about to build valid execution units`;
                    yield sendMessageToHeartbeatTopic(m2);
                    console.log(m1);
                    console.log(m2);
                    return offers.length;
                });
            }
            function buildUnits() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.log(`\n🕵 🕵 🕵 🕵 🕵  buildUnits: offers: ${offers.length} profiles: ${profiles.length} orders: ${orders.length} `);
                    try {
                        units = yield Matcher.Matcher.match(profiles, orders, offers);
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Matching fell down. ${e}`);
                    }
                    yield sendMessageToHeartbeatTopic(`💙  💚  💛  Matcher has created ${units.length} execution units. Ready to rumble!`);
                    console.log(`\n💙  💚  💛  +++ ExecutionUnits ready for processing, execution units: ${units.length}, offers : ${offers.length}`);
                    return units;
                });
            }
            function shuffleOrders() {
                console.log(orders);
                for (let i = orders.length - 1; i > 0; i--) {
                    const j = Math.floor(Math.random() * (i + 1));
                    [orders[i], orders[j]] = [orders[j], orders[i]];
                }
                console.log("\n🙈 🙈 🙈 shuffled orders ........check above vs below.. wtf?");
                console.log(orders);
            }
            function writeAutoTradeStart() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    yield fs
                        .collection(constants_1.Constants.FS_AUTOTRADE_STARTS)
                        .doc(startKey)
                        .set(autoTradeStart)
                        .catch(e => {
                        console.error(e);
                        throw e;
                    });
                    console.log(`\n\n☕️  ☕️  ☕️  autoTradeStart written to Firestore startKey: ${startKey}`);
                    return 0;
                });
            }
            function updateAutoTradeStart() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    autoTradeStart.dateEnded = new Date().toISOString();
                    let t = 0.0;
                    units.forEach(u => {
                        t += u.offer.offerAmount;
                    });
                    autoTradeStart.totalAmount = t;
                    let mf;
                    mf = yield fs
                        .collection(constants_1.Constants.FS_AUTOTRADE_STARTS)
                        .doc(startKey)
                        .set(autoTradeStart)
                        .catch(e => {
                        console.log(e);
                        throw e;
                    });
                    console.log("\n☕️  ☕️  ☕️   updated AutoTradeStart ######################");
                    return mf;
                });
            }
            function sendMessageToHeartbeatTopic(message) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
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
                    console.log("\n🚀 🚀 🚀 sending heartbeat to topic: " + mTopic);
                    return yield admin.messaging().sendToTopic(mTopic, payload);
                });
            }
        });
    }
}
exports.AutoTradeExecutor = AutoTradeExecutor;
//# sourceMappingURL=auto_trade_executor.js.map