export class Constants {
  //  static DEBUG_URL = "https://bfnrestv3.eu-gb.mybluemix.net/api/"; //FIBRE
  //  static RELEASE_URL = "https://bfnrestv3.eu-gb.mybluemix.net/api/"; //CLOUD
  static DEBUG_BFN_URL = "https://bfnwebapi1.eu-gb.mybluemix.net/"; //FIBRE
  static RELEASE_BFN_URL = "https://bfnwebapi1.eu-gb.mybluemix.net/"; //CLOUD
  static NameSpace = "com.oneconnect.biz.";
  static DEFAULT_CHAINCODE = "bfn-chaincode2";
  static DEFAULT_CHANNEL = "channel1";
  static DEFAULT_USERNAME = "org1admin";

  static DEBUG_FUNCTIONS_URL =
    "https://us-central1-business-finance-dev.cloudfunctions.net/"; //FIBRE
  static RELEASE_FUNCTIONS_URL =
    "https://us-central1-business-finance-prod.cloudfunctions.net/"; //CLOUD
  static PEACH_TEST_URL = "https://test.oppwa.com/";
  static PEACH_PROD_URL = "https://oppwa.com/";
  // Firestore constants
  static FS_USERS = "users";
  static FS_WALLETS = "wallets";
  static FS_CUSTOMERS = "customers";
  static FS_SUPPLIERS = "suppliers";
  static FS_INVESTORS = "investors";
  static FS_PURCHASE_ORDERS = "purchaseOrders";
  static FS_DELIVERY_NOTES = "deliveryNotes";
  static FS_DELIVERY_ACCEPTANCES = "deliveryAcceptances";
  static FS_INVOICES = "invoices";
  static FS_INVOICE_ACCEPTANCES = "invoiceAcceptances";
  static FS_OFFERS = "offers";
  static FS_FAILED_OFFERS = "failedOffers";
  static FS_INVOICE_BIDS = "invoiceBids";
  static FS_SETTLEMENTS = "settlement";
  static FS_PAYMENTS = "payments";
  static FS_COUNTRIES = "countries";
  static FS_SECTORS = "sectors";
  static FS_INVESTOR_PROFILES = "investorProfiles";
  static FS_AUTOTRADE_ORDERS = "autoTradeOrders";
  static FS_AUTOTRADE_STARTS = "autoTradeStarts";
  // Firebase Cloud Messaging Constants
  static TOPIC_PEACH_NOTIFY = "peachNotify";
  static TOPIC_PEACH_ERROR = "peachError";
  static TOPIC_PEACH_CANCEL = "peachCancel";
  static TOPIC_PEACH_SUCCESS = "peachSuccess";
  static TOPIC_PURCHASE_ORDERS = "purchaseOrders";
  static TOPIC_DELIVERY_NOTES = "deliveryNotes";
  static TOPIC_DELIVERY_ACCEPTANCES = "deliveryAcceptances";
  static TOPIC_INVOICES = "invoices";
  static TOPIC_INVOICE_ACCEPTANCES = "invoiceAcceptances";
  static TOPIC_OFFERS = "offers";
  static TOPIC_AUTO_TRADES = "autoTrades";
  static TOPIC_CHAT_MESSAGES_ADDED = "chatMessagesAdded";
  static TOPIC_CHAT_RESPONSES_ADDED = "chatResponsesAdded";
  static TOPIC_GENERAL_MESSAGE = "messages";
  static TOPIC_INVOICE_BIDS = "invoiceBids";
  static TOPIC_INVESTOR_INVOICE_SETTLEMENTS = "investorInvoiceSettlements";
  static TOPIC_SUPPLIERS = "suppliers";
  static TOPIC_CUSTOMERS = "customers";
  static TOPIC_INVESTORS = "investors";

  // chaincode function names
  static CHAIN_ADD_USER = "addUser";
  static CHAIN_ADD_CUSTOMER = "addCustomer";
  static CHAIN_ADD_COUNTRY = "addCountry";
  static CHAIN_ADD_SECTOR = "addSector";
  static CHAIN_ADD_SUPPLIER = "addSupplier";
  static CHAIN_ADD_INVESTOR = "addInvestor";
  static CHAIN_ADD_PURCHASE_ORDER = "addPurchaseOrder";
  static CHAIN_ADD_DELIVERY_NOTE = "addDeliveryNote";
  static CHAIN_ADD_DELIVERY_NOTE_ACCEPTANCE = "acceptDeliveryNote";
  static CHAIN_ADD_STELLAR_WALLET = "addStellarWallet";
  static CHAIN_ADD_INVOICE = "addInvoice";
  static CHAIN_ADD_INVOICE_ACCEPTANCE = "acceptInvoice";
  static CHAIN_ADD_OFFER = "addOffer";
  static CHAIN_CLOSE_OFFER = "closeOffer";
  static CHAIN_CANCEL_OFFER = "cancelOffer";
  static CHAIN_ADD_INVOICE_BID = "addInvoiceBid";
  static CHAIN_CANCEL_INVOICE_BID = "cancelInvoiceBid";
  static CHAIN_ADD_SETTLEMENT = "addInvoiceSettlement";

  static CHAIN_ADD_INVESTOR_PROFILE = "addInvestorProfile";
  static CHAIN_ADD_AUTOTRADE_ORDER = "addAutoTradeOrder";
  static CHAIN_ADD_AUTOTRADE_START = "addAutoTradeStart";
  ////
  static CHAIN_ADD_USERS = "addUsers";
  static CHAIN_ADD_CUSTOMERS = "addCustomers";
  static CHAIN_ADD_COUNTRIES = "addCountries";
  static CHAIN_ADD_SECTORS = "addSectors";
  static CHAIN_ADD_SUPPLIERS = "addSuppliers";
  static CHAIN_ADD_INVESTORS = "addInvestors";
  static CHAIN_ADD_PURCHASE_ORDERS = "addPurchaseOrders";
  static CHAIN_ADD_DELIVERY_NOTES = "addDeliveryNotes";
  static CHAIN_ADD_DELIVERY_NOTE_ACCEPTANCES = "acceptDeliveryNotes";
  static CHAIN_ADD_STELLAR_WALLETS = "addStellarWallets";
  static CHAIN_ADD_INVOICES = "addInvoices";
  static CHAIN_ADD_INVOICE_ACCEPTANCES = "acceptInvoices";
  static CHAIN_ADD_OFFERS = "addOffers";
  static CHAIN_ADD_INVESTOR_PROFILES = "addInvestorProfiles";
  static CHAIN_ADD_AUTOTRADE_ORDERS = "addAutoTradeOrders";
  ////

  static PEACH_USERID = "8ac7a4ca66f2eab3016706c87d6013e8";
  static PEACH_PASSWORD = "6PsDWg86RJ";
  static PEACH_ENTITYID_ONCEOFF = "8ac7a4ca66f2eab3016706c9812213ec";
  static PEACH_ENTITYID_RECURRING = "8ac7a4ca66f2eab3016706c9f4c113f0";

  static getDebugURL() {
    return this.DEBUG_BFN_URL;
  }
  static getReleaseURL() {
    return this.RELEASE_BFN_URL;
  }
}
