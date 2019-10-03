"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const admin = tslib_1.__importStar(require("firebase-admin"));
const constants_1 = require("../models/constants");
const z = "\n";
const serviceAccount = require('../services/admin-sdk.json');
console.log(`serviceAccount: 😍 😍 😍 ${serviceAccount}`);
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://business-finance-dev.firebaseio.com"
});
const fs = admin.firestore();
console.log(`💋  💋  💋  -- firebase admin initialized;  ❤️  SDK_VERSION: ${admin.SDK_VERSION}  😍 😍 😍 ${new Date().toUTCString()}`);
function getCollections() {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        const colRef = yield fs.getCollections();
        console.log(`💦 💦 💦 💦 collections in Firestore database: \n`);
        colRef.forEach((m) => {
            console.log(`❤️  ❤️  ❤️   Firestore collection: ${m.doc().path.split('/')[0]} 💦`);
        });
        console.log(`💦 💦 💦 💦 all collections listed: \n`);
        // const qs = await fs.collection('deliveryNotes').get();
        // qs.docs.forEach((doc) => {
        //   console.log(`☕️  ☕️  id: ${doc.data().deliveryNoteId} 💦 ${doc.data().date}  💦 supplier: ${doc.data().supplier}`)
        // })
        // console.log(`☕️  ☕️  ☕️  ☕️  ☕️  ☕️  ☕️  ☕️   ${qs.docs.length} deliveryNotes found`)
    });
}
getCollections();
class FirestoreService {
    static writeCustomer(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.participantId;
                const ref = yield fs.collection(constants_1.Constants.FS_CUSTOMERS).doc(key).set(jsonObj);
                const msg = `💦 💦  customer added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_CUSTOMERS}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore customer write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static writeUser(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.userId;
                const ref = yield fs.collection(constants_1.Constants.FS_USERS).doc(key).set(jsonObj);
                yield this.createAuthUser(jsonObj);
                const msg = `💦 💦  user added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_USERS}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore user write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static createAuthUser(user) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log(`🔵 🔵 🔵 Create Firebase auth user ... ${user}`);
            admin.auth().createUser({
                email: user.email,
                emailVerified: false,
                password: user.password,
                displayName: user.firstName + ' ' + user.lastName,
                disabled: false
            })
                .then(function (userRecord) {
                // See the UserRecord reference doc for the contents of userRecord.
                console.log('💚  💚  💚 Successfully created new auth user:', userRecord.uid);
            })
                .catch(function (error) {
                console.log('😡 😡 😡 😡 Error creating new auth user:', error);
            });
        });
    }
    static fixCountries(strings) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            for (const s of strings) {
                yield this.writeCountry(s);
            }
        });
    }
    static writeCountry(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.name;
                const ref = yield fs.collection(constants_1.Constants.FS_COUNTRIES).doc(key).set(jsonObj);
                const msg = `💦 💦  country added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_COUNTRIES}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore country write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static writeSector(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.sectorId;
                const ref = yield fs.collection(constants_1.Constants.FS_SECTORS).doc(key).set(jsonObj);
                const msg = `💦 💦  sector added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_SECTORS}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore sector write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static writeInvestorProfile(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.profileId;
                const ref = yield fs.collection(constants_1.Constants.FS_INVESTOR_PROFILES).doc(key).set(jsonObj);
                const msg = `💦 💦  profile added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_INVESTOR_PROFILES}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore profile write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static writeAutoTradeOrder(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.autoTradeOrderId;
                const ref = yield fs.collection(constants_1.Constants.FS_AUTOTRADE_ORDERS).doc(key).set(jsonObj);
                const msg = `💦 💦  AutoTradeOrder added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_AUTOTRADE_ORDERS}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore AutoTradeOrder write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static writeAutoTradeStart(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.autoTradeStartId;
                const ref = yield fs.collection(constants_1.Constants.FS_AUTOTRADE_STARTS).doc(key).set(jsonObj);
                const msg = `💦 💦  AutoTradeStart added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_AUTOTRADE_STARTS}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore AutoTradeStart write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static writeSupplier(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.participantId;
                const ref = yield fs.collection(constants_1.Constants.FS_SUPPLIERS).doc(key).set(jsonObj);
                const msg = `💦 💦  supplier added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_SUPPLIERS}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore supplier write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static writeInvestor(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                const key = jsonObj.participantId;
                const ref = yield fs.collection(constants_1.Constants.FS_INVESTORS).doc(key).set(jsonObj);
                const msg = `💦 💦  investor added to Firestore: ${ref.writeTime.toDate().toISOString()} ${constants_1.Constants.FS_INVESTORS}/${key}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore investor write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static writePurchaseOrder(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                yield fs.collection(constants_1.Constants.FS_PURCHASE_ORDERS).doc(jsonObj.purchaseOrderId).set(jsonObj);
                const msg = `💦  💦  purchase order added to Firestore: ${constants_1.Constants.FS_PURCHASE_ORDERS}/${jsonObj.purchaseOrderId}`;
                yield this.sendPurchaseOrderToTopic(jsonObj);
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore purchase order write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static sendPurchaseOrderToTopic(purchaseOrder) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const topic0 = constants_1.Constants.TOPIC_PURCHASE_ORDERS;
            const topic2 = constants_1.Constants.TOPIC_PURCHASE_ORDERS + purchaseOrder.supplier;
            const topic1 = constants_1.Constants.TOPIC_PURCHASE_ORDERS + purchaseOrder.customer;
            const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;
            const payload = {
                data: {
                    messageType: constants_1.Constants.TOPIC_PURCHASE_ORDERS,
                    json: JSON.stringify(purchaseOrder)
                },
                notification: {
                    title: "💥 💥 💥 Purchase Order",
                    body: "PurchaseOrder from " + purchaseOrder.customerName
                },
                condition: mCondition
            };
            console.log("💥 💥 💥  sending PurchaseOrder data to topic: " + mCondition);
            try {
                yield admin.messaging().send(payload);
            }
            catch (e) {
                console.error(e);
            }
            return null;
        });
    }
    static writeDeliveryNote(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                yield fs.collection(constants_1.Constants.FS_DELIVERY_NOTES).doc(jsonObj.deliveryNoteId).set(jsonObj);
                const msg = `💦  💦  deliveryNote added to Firestore: ${constants_1.Constants.FS_DELIVERY_NOTES}/${jsonObj.deliveryNoteId}`;
                yield this.sendDeliveryNoteToTopic(jsonObj);
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore deliveryNote write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static sendDeliveryNoteToTopic(deliveryNote) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const topic0 = constants_1.Constants.TOPIC_DELIVERY_NOTES;
            const topic2 = constants_1.Constants.TOPIC_DELIVERY_NOTES + deliveryNote.supplier;
            const topic1 = constants_1.Constants.TOPIC_DELIVERY_NOTES + deliveryNote.customer;
            const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;
            const payload = {
                data: {
                    messageType: constants_1.Constants.TOPIC_DELIVERY_NOTES,
                    json: JSON.stringify(deliveryNote)
                },
                notification: {
                    title: "💥 💥 💥 Delivery Note",
                    body: "Delivery Note from " + deliveryNote.supplierName
                },
                condition: mCondition
            };
            console.log("💥 💥 💥 sending delivery note data to topic: " + mCondition);
            try {
                yield admin.messaging().send(payload);
            }
            catch (e) {
                console.error(e);
            }
            return null;
        });
    }
    static writeDeliveryAcceptance(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                yield fs.collection(constants_1.Constants.FS_DELIVERY_ACCEPTANCES).doc(jsonObj.acceptanceId).set(jsonObj);
                const msg = `💦  💦  deliveryAcceptance added to Firestore: ${constants_1.Constants.FS_DELIVERY_ACCEPTANCES}/${jsonObj.acceptanceId}`;
                yield this.sendDeliveryAcceptanceToTopic(jsonObj);
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore deliveryAcceptance write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static sendDeliveryAcceptanceToTopic(acceptance) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const topic0 = constants_1.Constants.TOPIC_DELIVERY_ACCEPTANCES;
            const topic2 = constants_1.Constants.TOPIC_DELIVERY_ACCEPTANCES + acceptance.supplier;
            const topic1 = constants_1.Constants.TOPIC_DELIVERY_ACCEPTANCES + acceptance.customer;
            const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;
            const payload = {
                data: {
                    messageType: constants_1.Constants.TOPIC_DELIVERY_ACCEPTANCES,
                    json: JSON.stringify(acceptance)
                },
                notification: {
                    title: "💥 💥 💥 Delivery Acceptance",
                    body: "Delivery Acceptance from " + acceptance.supplierName
                },
                condition: mCondition
            };
            console.log("💥 💥 💥 sending delivery acceptance data to topic: " + mCondition);
            try {
                yield admin.messaging().send(payload);
            }
            catch (e) {
                console.error(e);
            }
            return null;
        });
    }
    static writeInvoice(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                yield fs.collection(constants_1.Constants.FS_INVOICES).doc(jsonObj.invoiceId).set(jsonObj);
                const msg = `💦  💦  invoice added to Firestore: ${constants_1.Constants.FS_INVOICES}/${jsonObj.invoiceId}`;
                yield this.sendInvoiceToTopic(jsonObj);
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore invoice write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static sendInvoiceToTopic(invoice) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const topic0 = constants_1.Constants.TOPIC_INVOICES;
            const topic2 = constants_1.Constants.TOPIC_INVOICES + invoice.supplier;
            const topic1 = constants_1.Constants.TOPIC_INVOICES + invoice.customer;
            const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;
            const payload = {
                data: {
                    messageType: constants_1.Constants.TOPIC_INVOICES,
                    json: JSON.stringify(invoice)
                },
                notification: {
                    title: "💥 💥 💥 Invoice",
                    body: "Invoice from " + invoice.supplierName
                },
                condition: mCondition
            };
            console.log("💥 💥 💥 sending Invoice data to topic: " + mCondition);
            try {
                yield admin.messaging().send(payload);
            }
            catch (e) {
                console.error(e);
            }
            return null;
        });
    }
    static writeInvoiceAcceptance(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                yield fs.collection(constants_1.Constants.FS_INVOICE_ACCEPTANCES).doc(jsonObj.acceptanceId).set(jsonObj);
                const snap = yield fs.collection(constants_1.Constants.FS_INVOICES).doc(jsonObj.invoice).get();
                const invoice = snap.data();
                invoice.invoiceAcceptance = jsonObj.acceptanceId;
                yield fs.collection(constants_1.Constants.FS_INVOICES).doc(invoice.invoiceId).set(invoice);
                const msg = `💦  💦  invoiceAcceptance added to Firestore, invoice updated: ${constants_1.Constants.FS_INVOICE_ACCEPTANCES}/${jsonObj.acceptanceId}`;
                yield this.sendInvoiceAcceptanceToTopic(jsonObj);
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore invoice acceptance write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static sendInvoiceAcceptanceToTopic(invoice) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const topic0 = constants_1.Constants.TOPIC_INVOICE_ACCEPTANCES;
            const topic2 = constants_1.Constants.TOPIC_INVOICE_ACCEPTANCES + invoice.supplier;
            const topic1 = constants_1.Constants.TOPIC_INVOICE_ACCEPTANCES + invoice.customer;
            const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;
            const payload = {
                data: {
                    messageType: constants_1.Constants.TOPIC_INVOICE_ACCEPTANCES,
                    json: JSON.stringify(invoice)
                },
                notification: {
                    title: "💥 💥 💥 Invoice Acceptance",
                    body: "Invoice Acceptance from " + invoice.customerName
                },
                condition: mCondition
            };
            console.log("💥 💥 💥 sending Invoice Acceptance data to topic: " + mCondition);
            try {
                yield admin.messaging().send(payload);
            }
            catch (e) {
                console.error(e);
            }
            return null;
        });
    }
    static writeOffer(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                yield fs.collection(constants_1.Constants.FS_OFFERS).doc(jsonObj.offerId).set(jsonObj);
                const msg = `💦  💦  offer added to Firestore: ${constants_1.Constants.FS_OFFERS}/${jsonObj.offerId}`;
                yield this.sendOfferToTopic(jsonObj);
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore offer write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static closeOffer(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                jsonObj.isOpen = false;
                yield fs.collection(constants_1.Constants.FS_OFFERS).doc(jsonObj.offerId).set(jsonObj);
                const msg = `💦 💦  ❎ ❎ ❎ offer closed on Firestore:  😡 ${constants_1.Constants.FS_OFFERS}/${jsonObj.offerId}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore offer close failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static cancelOffer(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                jsonObj.isCancelled = true;
                jsonObj.dateCancelled = new Date().toISOString();
                jsonObj.isOpen = false;
                yield fs.collection(constants_1.Constants.FS_OFFERS).doc(jsonObj.offerId).set(jsonObj);
                const msg = `💦 💦   🚼 🚼 🚼 offer cancelled on Firestore:  😡 ${constants_1.Constants.FS_OFFERS}/${jsonObj.offerId}`;
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore offer close failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static sendOfferToTopic(offer) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const topic0 = constants_1.Constants.TOPIC_OFFERS;
            const topic2 = constants_1.Constants.TOPIC_OFFERS + offer.supplier;
            const topic1 = constants_1.Constants.TOPIC_OFFERS + offer.customer;
            const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;
            const payload = {
                data: {
                    messageType: constants_1.Constants.TOPIC_OFFERS,
                    json: JSON.stringify(offer)
                },
                notification: {
                    title: "💥 💥 💥 Offer",
                    body: "Invoice Offer from " + offer.supplierName
                },
                condition: mCondition
            };
            console.log("💥 💥 💥 sending Offer data to topic: " + mCondition);
            try {
                yield admin.messaging().send(payload);
            }
            catch (e) {
                console.error(e);
            }
            return null;
        });
    }
    static writeInvoiceBid(jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            try {
                const jsonObj = JSON.parse(jsonString);
                yield fs.collection(constants_1.Constants.FS_INVOICE_BIDS).doc(jsonObj.invoiceBidId).set(jsonObj);
                const msg = `💦 💦 invoiceBid added to Firestore:  😡 ${constants_1.Constants.FS_INVOICE_BIDS}/${jsonObj.invoiceBidId}`;
                yield this.sendInvoiceBidToTopic(jsonObj);
                console.log(msg);
                return msg;
            }
            catch (e) {
                const msg = `👿 👿 👿 Firestore invoiceBid write failed : ${e}`;
                console.error(msg);
                throw new Error(msg);
            }
        });
    }
    static sendInvoiceBidToTopic(invoiceBid) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const topic0 = constants_1.Constants.TOPIC_INVOICE_BIDS;
            const topic2 = constants_1.Constants.TOPIC_INVOICE_BIDS + invoiceBid.supplier;
            const topic1 = constants_1.Constants.TOPIC_INVOICE_BIDS + invoiceBid.investor;
            const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;
            const payload = {
                data: {
                    messageType: constants_1.Constants.TOPIC_INVOICE_BIDS,
                    json: JSON.stringify(invoiceBid)
                },
                notification: {
                    title: "💥 💥 💥 Invoice",
                    body: "Invoice Bid from " + invoiceBid.investorName
                },
                condition: mCondition
            };
            console.log("💥 💥 💥 sending InvoiceBid data to topic: " + mCondition);
            try {
                yield admin.messaging().send(payload);
            }
            catch (e) {
                console.error(e);
            }
            return null;
        });
    }
}
exports.FirestoreService = FirestoreService;
//# sourceMappingURL=firestore-service.js.map