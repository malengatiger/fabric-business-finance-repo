"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const firestore_service_1 = require("./firestore-service");
const admin = tslib_1.__importStar(require("firebase-admin"));
const close_helper_1 = require("./close-helper");
const transaction_service_1 = require("./transaction-service");
const constants_1 = require("../models/constants");
class InvoiceBidHelper {
    static writeInvoiceBid(invoiceBid, contract) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`\n😡 😡 😡 😡 InvoiceBidHelper: 🥦 checking bid totals before sending bid to BFN: offerId: 😡 ${invoiceBid.offer}.... 😡 😡 😡 😡 `);
            const offerId = invoiceBid.offer;
            try {
                //final check before bid is made:
                const proceed = yield checkTotalBids();
                if (proceed === false) {
                    const msg = `\n🍷🍷🍷🍷 This offer is already fully bid at 🍷 100.0%  offerId: 😡 ${offerId} 😡 😡 😡 😡`;
                    throw new Error(`😈 😈 😈  ERROR: ${msg}`);
                }
                console.log(`🥦 InvoiceBidHelper: submit chaincode transaction to BFN  🌀 🌀 🌀 🌀 ... ${constants_1.Constants.CHAIN_ADD_INVOICE_BID} 🌀 🌀 🌀 🌀`);
                const mresponse = yield transaction_service_1.TransactionService.submit(contract, constants_1.Constants.CHAIN_ADD_INVOICE_BID, JSON.stringify(invoiceBid), 0);
                console.log(`💚 💚 💚  InvoiceBidHelper: TransactionService.send has returned from BFN, 🥦🥦🥦 status: 💕 💕 ${mresponse.statusCode} 💕 💕`);
                if (mresponse.statusCode === 200) {
                    yield firestore_service_1.FirestoreService.writeInvoiceBid(JSON.stringify(mresponse.result));
                    if (mresponse.result.reservePercent === 100.0) {
                        yield firestore_service_1.FirestoreService.closeOffer(JSON.stringify(mresponse.result));
                    }
                }
                return mresponse;
            }
            catch (error) {
                console.log(`InvoiceBidHelper: writeInvoiceBid error 😈 😈 😈 ${error}`);
                throw error;
            }
            function checkTotalBids() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    // console.log(
                    //   `\n😡 😡 checkTotalBids ......... offerId: ${offerId}`
                    // );
                    const start = new Date().getTime();
                    let total = 0.0;
                    let proceed = false;
                    try {
                        const msnapshot = yield admin
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
                        console.log(`💦 💦 💦  Queried invoiceBids for offer ${offerId} - ⌛️ ${end1 -
                            start} milliseconds elapsed. 🥒 bids found: ${msnapshot.docs.length} 🥒 `);
                        if (total >= 100.0) {
                            console.log(`\n🔵 🔵 🔵  closing offer, reservePercent == 😡 😡 ${total} %`);
                            yield close_helper_1.CloseHelper.writeCloseOfferToBFN(offerId, invoiceBid.supplier, invoiceBid.invoice, contract);
                            proceed = false;
                        }
                        else {
                            proceed = true;
                        }
                        return proceed;
                    }
                    catch (e) {
                        console.log("InvoiceBidHelper: checkTotalBids: 😈 😈 😈 -- PROBLEM -- ");
                        console.error(e);
                        throw e;
                    }
                });
            }
        });
    }
}
exports.InvoiceBidHelper = InvoiceBidHelper;
//# sourceMappingURL=invoice-bid-helper.js.map