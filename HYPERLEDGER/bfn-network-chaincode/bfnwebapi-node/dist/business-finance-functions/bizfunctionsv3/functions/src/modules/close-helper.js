"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const admin = tslib_1.__importStar(require("firebase-admin"));
const BFNConstants = tslib_1.__importStar(require("../models/constants"));
const AxiosComms = tslib_1.__importStar(require("./axios-comms"));
class CloseHelper {
    static writeCloseOfferToBFN(offerId, offerDocRef, debug) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            let url;
            const map = new Map();
            map["offerId"] = offerId;
            if (debug) {
                url = BFNConstants.Constants.DEBUG_BFN_URL + "CloseOffer";
            }
            else {
                url = BFNConstants.Constants.RELEASE_BFN_URL + "CloseOffer";
            }
            try {
                const mresponse = yield AxiosComms.AxiosComms.execute(url, map);
                if (mresponse.status === 200) {
                    return updateCloseOfferToFirestore();
                }
                else {
                    console.log(`******** BFN ERROR ########### mresponse.status: ${mresponse.status}`);
                    throw new Error(`BFN error  status: ${mresponse.status} ${mresponse.body}`);
                }
            }
            catch (error) {
                console.log("--------------- axios: BFN blockchain encountered a problem -----------------");
                console.log(error);
                throw error;
            }
            function updateCloseOfferToFirestore() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.log(`################### writeToFirestore, close Offer :${offerDocRef}`);
                    try {
                        const snapshot = yield admin
                            .firestore()
                            .collection("invoiceOffers")
                            .doc(offerDocRef)
                            .get();
                        const mData = snapshot.data();
                        mData.isOpen = false;
                        mData.dateClosed = new Date().toISOString();
                        yield snapshot.ref.set(mData);
                        console.log(`offer closed , isOpen set to false - updated on Firestore`);
                        console.log(`********************* offer data: ${JSON.stringify(mData)}`);
                        return null;
                    }
                    catch (e) {
                        console.log("##### ERROR, probably JSON data format related:");
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