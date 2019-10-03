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
Constants.DEFAULT_CHAINCODE = "bfn-chaincode1";
Constants.DEFAULT_CHANNEL = "defaultchannel";
Constants.DEFAULT_USERNAME = "admin@org1";
Constants.DEBUG_FUNCTIONS_URL = "https://us-central1-business-finance-dev.cloudfunctions.net/"; //FIBRE
Constants.RELEASE_FUNCTIONS_URL = "https://us-central1-business-finance-prod.cloudfunctions.net/"; //CLOUD
Constants.PEACH_TEST_URL = "https://test.oppwa.com/";
Constants.PEACH_PROD_URL = "https://oppwa.com/";
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
Constants.TOPIC_BFN_LOGALERTS = "bfnLogAlerts";
Constants.PEACH_USERID = "8ac7a4ca66f2eab3016706c87d6013e8";
Constants.PEACH_PASSWORD = "6PsDWg86RJ";
Constants.PEACH_ENTITYID_ONCEOFF = "8ac7a4ca66f2eab3016706c9812213ec";
Constants.PEACH_ENTITYID_RECURRING = "8ac7a4ca66f2eab3016706c9f4c113f0";
exports.Constants = Constants;
//# sourceMappingURL=constants.js.map