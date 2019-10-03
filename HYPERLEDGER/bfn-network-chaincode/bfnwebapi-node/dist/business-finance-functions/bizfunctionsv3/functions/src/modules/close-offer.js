"use strict";
// ######################################################################
// Add CloseOffer to BFN and update Firestore
// ######################################################################
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const functions = tslib_1.__importStar(require("firebase-functions"));
const admin = tslib_1.__importStar(require("firebase-admin"));
const close_helper_1 = require("./close-helper");
// const Firestore = require("firestore");
//curl --header "Content-Type: application/json"   --request POST   --data '{"offerId":"60bb1a50-c407-11e8-8c87-91c28e73e521", "debug": "true"}'   https://bfnrestv3.eu-gb.mybluemix.net/api/CloseOffer
exports.closeOffer = functions.https.onRequest((request, response) => tslib_1.__awaiter(this, void 0, void 0, function* () {
    if (!request.body) {
        console.log("ERROR - request has no body");
        return response.sendStatus(400);
    }
    try {
        const firestore = admin.firestore();
        const settings = { /* your settings... */ timestampsInSnapshots: true };
        firestore.settings(settings);
        console.log("Firebase settings completed. Should be free of annoying messages from Google");
    }
    catch (e) {
        console.log(e);
    }
    try {
        console.log(`##### Incoming debug ${request.body.debug}`);
        console.log(`##### Incoming offerId ${request.body.offerId}`);
        console.log(`##### Incoming offerDocRef ${request.body.offerDocRef}`);
        console.log(`##### Incoming data ${JSON.stringify(request.body.data)}`);
    }
    catch (e) { }
    const debug = request.body.debug;
    const offerId = request.body.offerId;
    const offerDocRef = request.body.offerDocRef;
    if (!offerId) {
        response.status(400).send(`Missing offerId`);
        return null;
    }
    if (!offerDocRef) {
        response.status(400).send(`Missing offerDocRef`);
        return null;
    }
    try {
        yield close_helper_1.CloseHelper.writeCloseOfferToBFN(offerId, offerDocRef, debug);
        response.status(200).send("Offer closed OK");
    }
    catch (e) {
        console.log(e);
        response.status(400).send(`Problem closing offer: ${e}`);
    }
    return null;
}));
//# sourceMappingURL=close-offer.js.map