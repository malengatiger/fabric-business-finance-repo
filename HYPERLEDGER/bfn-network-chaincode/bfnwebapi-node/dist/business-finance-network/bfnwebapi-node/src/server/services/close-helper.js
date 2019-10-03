"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const admin = tslib_1.__importStar(require("firebase-admin"));
const transaction_service_1 = require("./transaction-service");
const constants_1 = require("../models/constants");
class CloseHelper {
    static writeCloseOfferToBFN(offerId, supplier, invoice, contract) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`❇️  ❇️  ❇️  ❇️  ❇️   - writeCloseOfferToBFN: offerId: 😎 ${offerId} 🥒 supplier: ${supplier} 🥒 invoice: ${invoice}`);
            try {
                const mjson = {
                    offerId: offerId,
                    invoice: invoice,
                    supplier: supplier,
                };
                console.log(`sending closeOffer to BFN (TransactionService.submit): 😎 😎 😎 ${JSON.stringify(mjson)}`);
                const mresponse = yield transaction_service_1.TransactionService.submit(contract, constants_1.Constants.CHAIN_CLOSE_OFFER, JSON.stringify(mjson));
                console.log(`🍅 🍅 🍅 response from blockchain: 🥒 🥒 🥒 🥒 🥒 🥒 `);
                console.log(mresponse);
                if (mresponse.status === 200) {
                    console.log(`response status: 🍅 🍅 🍅 200 from blockchain, will update on Firestore ...`);
                    return updateCloseOfferToFirestore();
                }
                else {
                    console.log(`😈 😈 😈 BFN ERROR ########### mresponse.status: ${mresponse.status}  😈 😈 😈`);
                    throw new Error(`BFN error  status: ${mresponse.status} ${mresponse.body}`);
                }
            }
            catch (error) {
                console.log('😈 😈 😈 Close Offer failed at BFN 😈 😈 😈');
                console.log(error);
                throw error;
            }
            function updateCloseOfferToFirestore() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.log(`❄️ updateCloseOfferToFirestore: ❄️ ❄️ ❄️ close Offer: 😡 ${offerId} `);
                    try {
                        const snapshot = yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_OFFERS)
                            .doc(offerId)
                            .get();
                        if (snapshot.data()) {
                            console.log(`🍊 Offer found for closing: ☕️  ☕️  ☕️${snapshot.data}`);
                        }
                        let mData = snapshot.data();
                        mData.isOpen = false;
                        mData.dateClosed = new Date().toISOString();
                        yield snapshot.ref.set(mData);
                        console.log(`offer closed ,  ❄️ ❄️ ❄️ isOpen set to false - updated on Firestore`);
                        console.log(`********************* offer data on Firestore: 😎 😎 😎 ${JSON.stringify(mData)}`);
                        return null;
                    }
                    catch (e) {
                        console.log("😈 😈 😈 ERROR, probably JSON data format related: 😈 😈 😈");
                        console.log(e);
                        throw e;
                    }
                });
            }
        });
    }
}
exports.CloseHelper = CloseHelper;
//# sourceMappingURL=close-helper.js.map