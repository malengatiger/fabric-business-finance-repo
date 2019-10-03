import * as admin from "firebase-admin";
import { Firestore, CollectionReference } from "@google-cloud/firestore";
import { Constants } from "../models/constants";
const z = "\n";
const serviceAccount = require('../services/admin-sdk.json');
console.log(`serviceAccount: 😍 😍 😍 ${serviceAccount}`)
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://business-finance-dev.firebaseio.com"
});

const fs: Firestore = admin.firestore();
console.log(`💋  💋  💋  -- firebase admin initialized;  ❤️  SDK_VERSION: ${admin.SDK_VERSION}  😍 😍 😍 ${new Date().toUTCString()}`);

async function getCollections() {
  const colRef: CollectionReference[] = await fs.getCollections();
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
}
getCollections();

export class FirestoreService {
  public static async writeCustomer(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.participantId
      const ref = await fs.collection(Constants.FS_CUSTOMERS).doc(key).set(jsonObj);
      const msg = `💦 💦  customer added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_CUSTOMERS}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore customer write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writeUser(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.userId
      const ref = await fs.collection(Constants.FS_USERS).doc(key).set(jsonObj);

      await this.createAuthUser(jsonObj);
      const msg = `💦 💦  user added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_USERS}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore user write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async createAuthUser(user: any) {
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
  }
  public static async fixCountries(strings: string[]) {
    for (const s of strings) {
      await this.writeCountry(s);
    }
  }
  public static async writeCountry(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.name
      const ref = await fs.collection(Constants.FS_COUNTRIES).doc(key).set(jsonObj);
      const msg = `💦 💦  country added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_COUNTRIES}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore country write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writeSector(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.sectorId
      const ref = await fs.collection(Constants.FS_SECTORS).doc(key).set(jsonObj);
      const msg = `💦 💦  sector added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_SECTORS}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore sector write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writeInvestorProfile(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.profileId
      const ref = await fs.collection(Constants.FS_INVESTOR_PROFILES).doc(key).set(jsonObj);
      const msg = `💦 💦  profile added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_INVESTOR_PROFILES}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore profile write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writeAutoTradeOrder(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.autoTradeOrderId
      const ref = await fs.collection(Constants.FS_AUTOTRADE_ORDERS).doc(key).set(jsonObj);
      const msg = `💦 💦  AutoTradeOrder added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_AUTOTRADE_ORDERS}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore AutoTradeOrder write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writeAutoTradeStart(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.autoTradeStartId
      const ref = await fs.collection(Constants.FS_AUTOTRADE_STARTS).doc(key).set(jsonObj);
      const msg = `💦 💦  AutoTradeStart added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_AUTOTRADE_STARTS}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore AutoTradeStart write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writeSupplier(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.participantId
      const ref = await fs.collection(Constants.FS_SUPPLIERS).doc(key).set(jsonObj);
      const msg = `💦 💦  supplier added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_SUPPLIERS}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore supplier write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writeInvestor(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      const key = jsonObj.participantId
      const ref = await fs.collection(Constants.FS_INVESTORS).doc(key).set(jsonObj);
      const msg = `💦 💦  investor added to Firestore: ${ref.writeTime.toDate().toISOString()} ${Constants.FS_INVESTORS}/${key}`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore investor write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writePurchaseOrder(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      await fs.collection(Constants.FS_PURCHASE_ORDERS).doc(jsonObj.purchaseOrderId).set(jsonObj);
      const msg = `💦  purchase order added to Firestore: ${Constants.FS_PURCHASE_ORDERS}/${
        jsonObj.purchaseOrderId
        }`;
      await this.sendPurchaseOrderToTopic(jsonObj);
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore purchase order write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async sendPurchaseOrderToTopic(purchaseOrder: any) {
    const topic0 = Constants.TOPIC_PURCHASE_ORDERS;
    const topic2 = Constants.TOPIC_PURCHASE_ORDERS + purchaseOrder.supplier;
    const topic1 = Constants.TOPIC_PURCHASE_ORDERS + purchaseOrder.customer;

    const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;

    const payload = {
      data: {
        messageType: Constants.TOPIC_PURCHASE_ORDERS,
        json: JSON.stringify(purchaseOrder)
      },
      notification: {
        title: "💥 💥 💥 Purchase Order",
        body: "PurchaseOrder from " + purchaseOrder.customerName
      },
      condition: mCondition
    };

    console.log("💥 sending PurchaseOrder to topic:💥 " + mCondition);
    try {
      await admin.messaging().send(payload);
    } catch (e) {
      console.error(e);
    }
    return null;
  }
  public static async writeDeliveryNote(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      await fs.collection(Constants.FS_DELIVERY_NOTES).doc(jsonObj.deliveryNoteId).set(jsonObj);
      const msg = `💦  deliveryNote added to Firestore: ${Constants.FS_DELIVERY_NOTES}/${
        jsonObj.deliveryNoteId
        }`;
      await this.sendDeliveryNoteToTopic(jsonObj);
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore deliveryNote write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async sendDeliveryNoteToTopic(deliveryNote: any) {
    const topic0 = Constants.TOPIC_DELIVERY_NOTES;
    const topic2 = Constants.TOPIC_DELIVERY_NOTES + deliveryNote.supplier;
    const topic1 = Constants.TOPIC_DELIVERY_NOTES + deliveryNote.customer;

    const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;

    const payload = {
      data: {
        messageType: Constants.TOPIC_DELIVERY_NOTES,
        json: JSON.stringify(deliveryNote)
      },
      notification: {
        title: "💥 💥 💥 Delivery Note",
        body: "Delivery Note from " + deliveryNote.supplierName
      },
      condition: mCondition
    };

    console.log("💥 sending delivery note to topic:💥 " + mCondition);
    try {
      await admin.messaging().send(payload);
    } catch (e) {
      console.error(e);
    }
    return null;
  }
  public static async writeDeliveryAcceptance(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      await fs.collection(Constants.FS_DELIVERY_ACCEPTANCES).doc(jsonObj.acceptanceId).set(jsonObj);
      const msg = `💦  deliveryAcceptance added to Firestore: ${Constants.FS_DELIVERY_ACCEPTANCES}/${
        jsonObj.acceptanceId
        }`;
      await this.sendDeliveryAcceptanceToTopic(jsonObj);
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore deliveryAcceptance write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async sendDeliveryAcceptanceToTopic(acceptance: any) {
    const topic0 = Constants.TOPIC_DELIVERY_ACCEPTANCES;
    const topic2 = Constants.TOPIC_DELIVERY_ACCEPTANCES + acceptance.supplier;
    const topic1 = Constants.TOPIC_DELIVERY_ACCEPTANCES + acceptance.customer;

    const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;

    const payload = {
      data: {
        messageType: Constants.TOPIC_DELIVERY_ACCEPTANCES,
        json: JSON.stringify(acceptance)
      },
      notification: {
        title: "💥 💥 💥 Delivery Acceptance",
        body: "Delivery Acceptance from " + acceptance.supplierName
      },
      condition: mCondition
    };

    console.log("💥 sending delivery acceptance to topic:💥 " + mCondition);
    try {
      await admin.messaging().send(payload);
    } catch (e) {
      console.error(e);
    }
    return null;
  }
  public static async writeInvoice(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      await fs.collection(Constants.FS_INVOICES).doc(jsonObj.invoiceId).set(jsonObj);
      const msg = `💦  invoice added to Firestore: ${Constants.FS_INVOICES}/${
        jsonObj.invoiceId
        }`;
      await this.sendInvoiceToTopic(jsonObj);
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore invoice write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async sendInvoiceToTopic(invoice: any) {
    const topic0 = Constants.TOPIC_INVOICES;
    const topic2 = Constants.TOPIC_INVOICES + invoice.supplier;
    const topic1 = Constants.TOPIC_INVOICES + invoice.customer;

    const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;

    const payload = {
      data: {
        messageType: Constants.TOPIC_INVOICES,
        json: JSON.stringify(invoice)
      },
      notification: {
        title: "💥 💥 💥 Invoice",
        body: "Invoice from " + invoice.supplierName
      },
      condition: mCondition
    };

    console.log("💥 sending Invoice to topic:💥 " + mCondition);
    try {
      await admin.messaging().send(payload);
    } catch (e) {
      console.error(e);
    }
    return null;
  }
  public static async writeInvoiceAcceptance(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      await fs.collection(Constants.FS_INVOICE_ACCEPTANCES).doc(jsonObj.acceptanceId).set(jsonObj);

      const snap = await fs.collection(Constants.FS_INVOICES).doc(jsonObj.invoice).get();
      const invoice: any = snap.data();
      invoice.invoiceAcceptance = jsonObj.acceptanceId;
      await fs.collection(Constants.FS_INVOICES).doc(invoice.invoiceId).set(invoice);
      const msg = `💦  invoiceAcceptance added to Firestore, 💥 invoice updated: ${Constants.FS_INVOICE_ACCEPTANCES}/${
        jsonObj.acceptanceId
        }`;
      await this.sendInvoiceAcceptanceToTopic(jsonObj);
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore invoice acceptance write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async sendInvoiceAcceptanceToTopic(invoice: any) {
    const topic0 = Constants.TOPIC_INVOICE_ACCEPTANCES;
    const topic2 = Constants.TOPIC_INVOICE_ACCEPTANCES + invoice.supplier;
    const topic1 = Constants.TOPIC_INVOICE_ACCEPTANCES + invoice.customer;

    const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;

    const payload = {
      data: {
        messageType: Constants.TOPIC_INVOICE_ACCEPTANCES,
        json: JSON.stringify(invoice)
      },
      notification: {
        title: "💥 💥 💥 Invoice Acceptance",
        body: "Invoice Acceptance from " + invoice.customerName
      },
      condition: mCondition
    };

    console.log("💥 sending Invoice Acceptance to topic:💥 " + mCondition);
    try {
      await admin.messaging().send(payload);
    } catch (e) {
      console.error(e);
    }
    return null;
  }
  public static async writeOffer(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      await fs.collection(Constants.FS_OFFERS).doc(jsonObj.offerId).set(jsonObj);
      const msg = `💦  offer added to Firestore: ${Constants.FS_OFFERS}/${
        jsonObj.offerId
        }`;
      await this.sendOfferToTopic(jsonObj);
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore offer write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async writeFailedOffer(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      jsonObj.dateFailed = new Date().toISOString();
      const ref = await fs.collection(Constants.FS_FAILED_OFFERS).add(jsonObj);
      const msg = `🌶🌶  failedOffer added to Firestore: 🌶 ${ref.path} - 🎁 offerAmount: 💙 ${jsonObj.offerAmount.toFixed(2)} \tdiscountPercent: 💙❤️ ${jsonObj.discountPercent.toFixed(2)} % 🥦 ${jsonObj.supplierName}`;
      //await this.sendOfferToTopic(jsonObj);
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore failedOffer write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async closeOffer(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      jsonObj.isOpen = false;
      await fs.collection(Constants.FS_OFFERS).doc(jsonObj.offerId).set(jsonObj);
      const msg = `❎ ❎ ❎ offer closed on Firestore:  😡 ${Constants.FS_OFFERS}/${
        jsonObj.offerId
        }`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore offer close failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  public static async cancelOffer(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      jsonObj.isCancelled = true;
      jsonObj.dateCancelled = new Date().toISOString();
      jsonObj.isOpen = false;
      await fs.collection(Constants.FS_OFFERS).doc(jsonObj.offerId).set(jsonObj);
      const msg = `🚼 🚼 🚼 offer cancelled on Firestore:  😡 ${Constants.FS_OFFERS}/${
        jsonObj.offerId
        }`;
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore offer close failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async sendOfferToTopic(offer: any) {
    const topic0 = Constants.TOPIC_OFFERS;
    const topic2 = Constants.TOPIC_OFFERS + offer.supplier;
    const topic1 = Constants.TOPIC_OFFERS + offer.customer;

    const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;

    const payload = {
      data: {
        messageType: Constants.TOPIC_OFFERS,
        json: JSON.stringify(offer)
      },
      notification: {
        title: "💥 💥 💥 Offer",
        body: "Invoice Offer from " + offer.supplierName
      },
      condition: mCondition
    };

    console.log("💥 sending Offer to topic:💥 " + mCondition);
    try {
      await admin.messaging().send(payload);
    } catch (e) {
      console.error(e);
    }
    return null;
  }
  public static async writeInvoiceBid(jsonString: any): Promise<any> {
    try {
      const jsonObj: any = JSON.parse(jsonString);
      await fs.collection(Constants.FS_INVOICE_BIDS).doc(jsonObj.invoiceBidId).set(jsonObj);
      const msg = `💦 invoiceBid added to Firestore:  😡 ${Constants.FS_INVOICE_BIDS}/${
        jsonObj.invoiceBidId
        }`;
      await this.sendInvoiceBidToTopic(jsonObj);
      console.log(msg);
      return msg;
    } catch (e) {
      const msg = `👿 👿 👿 Firestore invoiceBid write failed : ${e}`;
      console.error(msg);
      throw new Error(msg);
    }
  }
  private static async sendInvoiceBidToTopic(invoiceBid: any) {
    const topic0 = Constants.TOPIC_INVOICE_BIDS;
    const topic2 = Constants.TOPIC_INVOICE_BIDS + invoiceBid.supplier;
    const topic1 = Constants.TOPIC_INVOICE_BIDS + invoiceBid.investor;

    const mCondition = `'${topic0}' in topics || '${topic2}' in topics || '${topic1}' in topics`;

    const payload = {
      data: {
        messageType: Constants.TOPIC_INVOICE_BIDS,
        json: JSON.stringify(invoiceBid)
      },
      notification: {
        title: "💥 💥 💥 Invoice",
        body: "Invoice Bid from " + invoiceBid.investorName
      },
      condition: mCondition
    };

    console.log("💥 sending InvoiceBid to topic:💥 " + mCondition);
    try {
      await admin.messaging().send(payload);
    } catch (e) {
      console.error(e);
    }
    return null;
  }
}
