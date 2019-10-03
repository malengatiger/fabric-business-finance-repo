"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const constants_1 = require("./../models/constants");
const admin = tslib_1.__importStar(require("firebase-admin"));
class ListService {
    static getCustomerDashboard(customer) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log('🔆 🔆 🔆 getting customer dashboard');
            const result = {
                totalOpenOffers: 0,
                totalOpenOfferAmount: 0.00,
                totalUnsettledBids: 0,
                totalUnsettledAmount: 0.00,
                totalPurchaseOrderAmount: 0.00,
                totalInvoiceAmount: 0.00,
                totalSettledBids: 0,
                totalSettledAmount: 0.00,
                totalBids: 0,
                totalBidAmount: 0.00,
                date: new Date().toISOString(),
                averageBidAmount: 0.00,
                averageDiscountPerc: 0.0,
                totalOfferAmount: 0.00,
                totalDeliveryNoteAmount: 0.00,
                totalOffers: 0,
                purchaseOrders: 0,
                invoices: 0,
                deliveryNotes: 0,
                cancelledOffers: 0,
                closedOffers: 0
            };
            yield getDeliveryNotes();
            return result;
            function getDeliveryNotes() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_DELIVERY_NOTES)
                            .where('customer', '==', customer)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.deliveryNotes = qSnap.docs.length;
                            qSnap.forEach(doc => {
                                result.totalDeliveryNoteAmount += doc.data().amount;
                            });
                            return yield getPurchaseOrders();
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query delivery notes: ${e}`);
                    }
                });
            }
            function getPurchaseOrders() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_PURCHASE_ORDERS)
                            .where('customer', '==', customer)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.purchaseOrders = qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalPurchaseOrderAmount += doc.data().amount;
                            });
                            return yield getInvoices();
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query purchase orders: ${e}`);
                    }
                    return null;
                });
            }
            function getInvoices() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_INVOICES)
                            .where('customer', '==', customer)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.invoices = qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalInvoiceAmount += doc.data().amount;
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query invoices: ${e}`);
                    }
                    return null;
                });
            }
        });
    }
    static getSupplierDashboard(supplier) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log('🔆 🔆 🔆 getting supplier dashboard ...');
            const result = {
                totalOpenOffers: 0,
                totalOpenOfferAmount: 0.00,
                totalClosedOffers: 0,
                totalClosedOfferAmount: 0.00,
                totalUnsettledBids: 0,
                totalUnsettledAmount: 0.00,
                totalPurchaseOrderAmount: 0.00,
                totalInvoiceAmount: 0.00,
                totalSettledBids: 0,
                totalSettledAmount: 0.00,
                totalBids: 0,
                totalBidAmount: 0.00,
                date: new Date().toISOString(),
                averageBidAmount: 0.00,
                averageDiscountPerc: 0.0,
                totalOfferAmount: 0.00,
                totalDeliveryNoteAmount: 0.00,
                totalOffers: 0,
                purchaseOrders: 0,
                invoices: 0,
                deliveryNotes: 0,
                cancelledOffers: 0,
                closedOffers: 0,
                totalInvoiceBids: 0,
            };
            yield getDeliveryNotes();
            yield getPurchaseOrders();
            yield getInvoices();
            yield getOpenOffers();
            yield getClosedOffers();
            yield getInvoiceBids();
            return result;
            function getDeliveryNotes() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_DELIVERY_NOTES)
                            .where('supplier', '==', supplier)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.deliveryNotes = qSnap.docs.length;
                            qSnap.forEach(doc => {
                                result.totalDeliveryNoteAmount += doc.data().amount;
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query delivery notes: ${e}`);
                    }
                });
            }
            function getPurchaseOrders() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_PURCHASE_ORDERS)
                            .where('supplier', '==', supplier)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.purchaseOrders = qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalPurchaseOrderAmount += doc.data().amount;
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query purchase orders: ${e}`);
                    }
                    return null;
                });
            }
            function getInvoices() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_INVOICES)
                            .where('supplier', '==', supplier)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.invoices = qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalInvoiceAmount += doc.data().amount;
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query invoices: ${e}`);
                    }
                    return null;
                });
            }
            function getOpenOffers() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_OFFERS)
                            .where('supplier', '==', supplier)
                            .where('isOpen', '==', true)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.totalOpenOffers = qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalOpenOfferAmount += doc.data().offerAmount;
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query open offers: ${e}`);
                    }
                    return null;
                });
            }
            function getClosedOffers() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_OFFERS)
                            .where('supplier', '==', supplier)
                            .where('isOpen', '==', false)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.totalClosedOffers = qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalClosedOfferAmount += doc.data().offerAmount;
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query closed offers: ${e}`);
                    }
                    return null;
                });
            }
            function getInvoiceBids() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_INVOICE_BIDS)
                            .where('supplier', '==', supplier)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.totalInvoiceBids = qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalBidAmount += doc.data().amount;
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query invoiceBids: ${e}`);
                    }
                    return null;
                });
            }
        });
    }
    static getInvestorDashboard(investor) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.log('🔆 🔆 🔆 getting investor dashboard');
            const settledBids = [];
            const unsettledBids = [];
            const settlements = [];
            const openOffers = [];
            const result = {
                totalOpenOffers: 0,
                totalOpenOfferAmount: 0.0,
                totalUnsettledBids: 0,
                totalUnsettledAmount: 0.0,
                totalSettledBids: 0,
                totalSettledAmount: 0.0,
                totalBids: 0,
                totalBidAmount: 0.0,
                date: new Date().toISOString(),
                investorId: investor,
                averageBidAmount: 0.0,
                averageDiscountPerc: 0.0,
                totalOfferAmount: 0.0,
                totalOffers: 0,
                'unsettledBids': unsettledBids,
                'settledBids': settledBids,
                'settlements': settlements,
                'openOffers': openOffers,
                totalSettlements: 0,
                totalSettlementAmount: 0.0
            };
            yield getOpenOffers();
            yield getSettledInvoiceBids();
            yield getUnSettledInvoiceBids();
            yield getSettlements();
            return result;
            function getOpenOffers() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_OFFERS)
                            .where('isOpen', '==', true)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.totalOpenOffers = qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalOpenOfferAmount += doc.data().offerAmount;
                                result.openOffers.push(doc.data());
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query open offers: ${e}`);
                    }
                    return null;
                });
            }
            function getSettledInvoiceBids() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_INVOICE_BIDS)
                            .where('investor', '==', investor)
                            .where('isSettled', '==', true)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.totalBids = qSnap.docs.length;
                            result.totalBids += qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalBidAmount += doc.data().amount;
                                result.settledBids.push(doc.data());
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query invoiceBids: ${e}`);
                    }
                    return null;
                });
            }
            function getUnSettledInvoiceBids() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    try {
                        yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_INVOICE_BIDS)
                            .where('investor', '==', investor)
                            .where('isSettled', '==', false)
                            .get()
                            .then((qSnap) => tslib_1.__awaiter(this, void 0, void 0, function* () {
                            result.totalUnsettledBids = qSnap.docs.length;
                            result.totalBids += qSnap.docs.length;
                            qSnap.docs.forEach(doc => {
                                result.totalUnsettledAmount += doc.data().amount;
                                result.unsettledBids.push(doc.data());
                            });
                            return null;
                        }));
                    }
                    catch (e) {
                        console.log(e);
                        throw new Error(`Failed to query invoiceBids: ${e}`);
                    }
                    return null;
                });
            }
            function getSettlements() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    let querySnapshot;
                    try {
                        querySnapshot = yield admin
                            .firestore()
                            .collection(constants_1.Constants.FS_SETTLEMENTS)
                            .where("investor", "==", investor)
                            .orderBy("date", "desc")
                            .limit(1000)
                            .get();
                        console.log(`investor settlements found ${querySnapshot.docs.length} `);
                        querySnapshot.docs.forEach(doc => {
                            result.totalSettlementAmount += doc.data().amount;
                            result.totalSettlements++;
                            result.settlements.push(doc.data());
                        });
                        return null;
                    }
                    catch (e) {
                        console.log(e);
                        throw e;
                    }
                });
            }
        });
    }
}
exports.ListService = ListService;
//# sourceMappingURL=list-service.js.map