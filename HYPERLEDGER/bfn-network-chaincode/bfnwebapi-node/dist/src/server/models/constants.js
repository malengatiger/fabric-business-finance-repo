"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class Constants {
    static getDebugURL() {
        return this.DEBUG_BFN_URL;
    }
    static getReleaseURL() {
        return this.RELEASE_BFN_URL;
    }
}
//  static DEBUG_URL = "https://bfnrestv3.eu-gb.mybluemix.net/api/"; //FIBRE
//  static RELEASE_URL = "https://bfnrestv3.eu-gb.mybluemix.net/api/"; //CLOUD
Constants.DEBUG_BFN_URL = "https://bfnwebapi1.eu-gb.mybluemix.net/"; //FIBRE
Constants.RELEASE_BFN_URL = "https://bfnwebapi1.eu-gb.mybluemix.net/"; //CLOUD
Constants.NameSpace = "com.oneconnect.biz.";
Constants.DEFAULT_CHAINCODE = "bfn-chaincode2";
Constants.DEFAULT_CHANNEL = "channel1";
Constants.DEFAULT_USERNAME = "org1admin";
Constants.DEBUG_FUNCTIONS_URL = "https://us-central1-business-finance-dev.cloudfunctions.net/"; //FIBRE
Constants.RELEASE_FUNCTIONS_URL = "https://us-central1-business-finance-prod.cloudfunctions.net/"; //CLOUD
Constants.PEACH_TEST_URL = "https://test.oppwa.com/";
Constants.PEACH_PROD_URL = "https://oppwa.com/";
// Firestore constants
Constants.FS_USERS = "users";
Constants.FS_WALLETS = "wallets";
Constants.FS_CUSTOMERS = "customers";
Constants.FS_SUPPLIERS = "suppliers";
Constants.FS_INVESTORS = "investors";
Constants.FS_PURCHASE_ORDERS = "purchaseOrders";
Constants.FS_DELIVERY_NOTES = "deliveryNotes";
Constants.FS_DELIVERY_ACCEPTANCES = "deliveryAcceptances";
Constants.FS_INVOICES = "invoices";
Constants.FS_INVOICE_ACCEPTANCES = "invoiceAcceptances";
Constants.FS_OFFERS = "offers";
Constants.FS_FAILED_OFFERS = "failedOffers";
Constants.FS_INVOICE_BIDS = "invoiceBids";
Constants.FS_SETTLEMENTS = "settlement";
Constants.FS_PAYMENTS = "payments";
Constants.FS_COUNTRIES = "countries";
Constants.FS_SECTORS = "sectors";
Constants.FS_INVESTOR_PROFILES = "investorProfiles";
Constants.FS_AUTOTRADE_ORDERS = "autoTradeOrders";
Constants.FS_AUTOTRADE_STARTS = "autoTradeStarts";
// Firebase Cloud Messaging Constants
Constants.TOPIC_PEACH_NOTIFY = "peachNotify";
Constants.TOPIC_PEACH_ERROR = "peachError";
Constants.TOPIC_PEACH_CANCEL = "peachCancel";
Constants.TOPIC_PEACH_SUCCESS = "peachSuccess";
Constants.TOPIC_PURCHASE_ORDERS = "purchaseOrders";
Constants.TOPIC_DELIVERY_NOTES = "deliveryNotes";
Constants.TOPIC_DELIVERY_ACCEPTANCES = "deliveryAcceptances";
Constants.TOPIC_INVOICES = "invoices";
Constants.TOPIC_INVOICE_ACCEPTANCES = "invoiceAcceptances";
Constants.TOPIC_OFFERS = "offers";
Constants.TOPIC_AUTO_TRADES = "autoTrades";
Constants.TOPIC_CHAT_MESSAGES_ADDED = "chatMessagesAdded";
Constants.TOPIC_CHAT_RESPONSES_ADDED = "chatResponsesAdded";
Constants.TOPIC_GENERAL_MESSAGE = "messages";
Constants.TOPIC_INVOICE_BIDS = "invoiceBids";
Constants.TOPIC_INVESTOR_INVOICE_SETTLEMENTS = "investorInvoiceSettlements";
Constants.TOPIC_SUPPLIERS = "suppliers";
Constants.TOPIC_CUSTOMERS = "customers";
Constants.TOPIC_INVESTORS = "investors";
// chaincode function names
Constants.CHAIN_ADD_USER = "addUser";
Constants.CHAIN_ADD_CUSTOMER = "addCustomer";
Constants.CHAIN_ADD_COUNTRY = "addCountry";
Constants.CHAIN_ADD_SECTOR = "addSector";
Constants.CHAIN_ADD_SUPPLIER = "addSupplier";
Constants.CHAIN_ADD_INVESTOR = "addInvestor";
Constants.CHAIN_ADD_PURCHASE_ORDER = "addPurchaseOrder";
Constants.CHAIN_ADD_DELIVERY_NOTE = "addDeliveryNote";
Constants.CHAIN_ADD_DELIVERY_NOTE_ACCEPTANCE = "acceptDeliveryNote";
Constants.CHAIN_ADD_STELLAR_WALLET = "addStellarWallet";
Constants.CHAIN_ADD_INVOICE = "addInvoice";
Constants.CHAIN_ADD_INVOICE_ACCEPTANCE = "acceptInvoice";
Constants.CHAIN_ADD_OFFER = "addOffer";
Constants.CHAIN_CLOSE_OFFER = "closeOffer";
Constants.CHAIN_CANCEL_OFFER = "cancelOffer";
Constants.CHAIN_ADD_INVOICE_BID = "addInvoiceBid";
Constants.CHAIN_CANCEL_INVOICE_BID = "cancelInvoiceBid";
Constants.CHAIN_ADD_SETTLEMENT = "addInvoiceSettlement";
Constants.CHAIN_ADD_INVESTOR_PROFILE = "addInvestorProfile";
Constants.CHAIN_ADD_AUTOTRADE_ORDER = "addAutoTradeOrder";
Constants.CHAIN_ADD_AUTOTRADE_START = "addAutoTradeStart";
////
Constants.CHAIN_ADD_USERS = "addUsers";
Constants.CHAIN_ADD_CUSTOMERS = "addCustomers";
Constants.CHAIN_ADD_COUNTRIES = "addCountries";
Constants.CHAIN_ADD_SECTORS = "addSectors";
Constants.CHAIN_ADD_SUPPLIERS = "addSuppliers";
Constants.CHAIN_ADD_INVESTORS = "addInvestors";
Constants.CHAIN_ADD_PURCHASE_ORDERS = "addPurchaseOrders";
Constants.CHAIN_ADD_DELIVERY_NOTES = "addDeliveryNotes";
Constants.CHAIN_ADD_DELIVERY_NOTE_ACCEPTANCES = "acceptDeliveryNotes";
Constants.CHAIN_ADD_STELLAR_WALLETS = "addStellarWallets";
Constants.CHAIN_ADD_INVOICES = "addInvoices";
Constants.CHAIN_ADD_INVOICE_ACCEPTANCES = "acceptInvoices";
Constants.CHAIN_ADD_OFFERS = "addOffers";
Constants.CHAIN_ADD_INVESTOR_PROFILES = "addInvestorProfiles";
Constants.CHAIN_ADD_AUTOTRADE_ORDERS = "addAutoTradeOrders";
////
Constants.PEACH_USERID = "8ac7a4ca66f2eab3016706c87d6013e8";
Constants.PEACH_PASSWORD = "6PsDWg86RJ";
Constants.PEACH_ENTITYID_ONCEOFF = "8ac7a4ca66f2eab3016706c9812213ec";
Constants.PEACH_ENTITYID_RECURRING = "8ac7a4ca66f2eab3016706c9f4c113f0";
exports.Constants = Constants;
//# sourceMappingURL=constants.js.map