import { Constants } from './../models/constants';
import * as admin from "firebase-admin";

export class ListService {

    public static async getCustomerDashboard(customer: string): Promise<any> {

        console.log('🔆 🔆 🔆 getting customer dashboard')
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
        await getDeliveryNotes();
        return result;

        async function getDeliveryNotes() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_DELIVERY_NOTES)
                    .where('customer', '==', customer)
                    .get()
                    .then(async qSnap => {
                        result.deliveryNotes = qSnap.docs.length;
                        qSnap.forEach(doc => {
                            result.totalDeliveryNoteAmount += doc.data().amount
                        })
                        return await getPurchaseOrders();
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query delivery notes: ${e}`);
            }
        }
        async function getPurchaseOrders() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_PURCHASE_ORDERS)
                    .where('customer', '==', customer)
                    .get()
                    .then(async qSnap => {
                        result.purchaseOrders = qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalPurchaseOrderAmount += doc.data().amount
                        })
                        return await getInvoices();
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query purchase orders: ${e}`);
            }
            return null;
        }
        async function getInvoices() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_INVOICES)
                    .where('customer', '==', customer)
                    .get()
                    .then(async qSnap => {
                        result.invoices = qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalInvoiceAmount += doc.data().amount
                        })
                        return null
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query invoices: ${e}`);
            }
            return null;
        }
    }
    public static async getSupplierDashboard(supplier: string): Promise<any> {

        console.log('🔆 🔆 🔆 getting supplier dashboard ...')
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
        await getDeliveryNotes();
        await getPurchaseOrders();
        await getInvoices();
        await getOpenOffers();
        await getClosedOffers();
        await getInvoiceBids();
        return result;

        async function getDeliveryNotes() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_DELIVERY_NOTES)
                    .where('supplier', '==', supplier)
                    .get()
                    .then(async qSnap => {
                        result.deliveryNotes = qSnap.docs.length;
                        qSnap.forEach(doc => {
                            result.totalDeliveryNoteAmount += doc.data().amount
                        })
                        return null;
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query delivery notes: ${e}`);
            }
        }
        async function getPurchaseOrders() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_PURCHASE_ORDERS)
                    .where('supplier', '==', supplier)
                    .get()
                    .then(async qSnap => {
                        result.purchaseOrders = qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalPurchaseOrderAmount += doc.data().amount
                        })
                        return null;
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query purchase orders: ${e}`);
            }
            return null;
        }
        async function getInvoices() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_INVOICES)
                    .where('supplier', '==', supplier)
                    .get()
                    .then(async qSnap => {
                        result.invoices = qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalInvoiceAmount += doc.data().amount
                        })
                        return null
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query invoices: ${e}`);
            }
            return null;
        }
        async function getOpenOffers() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_OFFERS)
                    .where('supplier', '==', supplier)
                    .where('isOpen', '==', true)
                    .get()
                    .then(async qSnap => {
                        result.totalOpenOffers = qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalOpenOfferAmount += doc.data().offerAmount
                        })
                        return null
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query open offers: ${e}`);
            }
            return null;
        }
        async function getClosedOffers() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_OFFERS)
                    .where('supplier', '==', supplier)
                    .where('isOpen', '==', false)
                    .get()
                    .then(async qSnap => {
                        result.totalClosedOffers = qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalClosedOfferAmount += doc.data().offerAmount
                        })
                        return null
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query closed offers: ${e}`);
            }
            return null;
        }
        async function getInvoiceBids() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_INVOICE_BIDS)
                    .where('supplier', '==', supplier)
                    .get()
                    .then(async qSnap => {
                        result.totalInvoiceBids = qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalBidAmount += doc.data().amount
                        })
                        return null
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query invoiceBids: ${e}`);
            }
            return null;
        }
    }
    public static async getInvestorDashboard(investor: string): Promise<any> {

        console.log('🔆 🔆 🔆 getting investor dashboard')
        const settledBids: any[] = [];
        const unsettledBids: any[] = [];
        const settlements: any[] = [];
        const openOffers: any[] = [];
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

        await getOpenOffers();
        await getSettledInvoiceBids();
        await getUnSettledInvoiceBids();
        await getSettlements();
        return result;

        async function getOpenOffers() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_OFFERS)
                    .where('isOpen', '==', true)
                    .get()
                    .then(async qSnap => {
                        result.totalOpenOffers = qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalOpenOfferAmount += doc.data().offerAmount;
                            result.openOffers.push(doc.data());
                        })
                        return null
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query open offers: ${e}`);
            }
            return null;
        }
        async function getSettledInvoiceBids() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_INVOICE_BIDS)
                    .where('investor', '==', investor)
                    .where('isSettled', '==', true)
                    .get()
                    .then(async qSnap => {
                        result.totalBids = qSnap.docs.length;
                        result.totalBids += qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalBidAmount += doc.data().amount;
                            result.settledBids.push(doc.data());
                        })
                        return null
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query invoiceBids: ${e}`);
            }
            return null;
        }
        async function getUnSettledInvoiceBids() {
            try {
                await admin
                    .firestore()
                    .collection(Constants.FS_INVOICE_BIDS)
                    .where('investor', '==', investor)
                    .where('isSettled', '==', false)
                    .get()
                    .then(async qSnap => {
                        result.totalUnsettledBids = qSnap.docs.length;
                        result.totalBids += qSnap.docs.length;
                        qSnap.docs.forEach(doc => {
                            result.totalUnsettledAmount += doc.data().amount;
                            result.unsettledBids.push(doc.data());
                        })
                        return null
                    });
            } catch (e) {
                console.log(e);
                throw new Error(`Failed to query invoiceBids: ${e}`);
            }
            return null;
        }
        async function getSettlements() {
            let querySnapshot;
            try {
                querySnapshot = await admin
                    .firestore()
                    .collection(Constants.FS_SETTLEMENTS)
                    .where(
                        "investor",
                        "==", investor
                    )
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
            } catch (e) {
                console.log(e);
                throw e;
            }
        }

    }
}