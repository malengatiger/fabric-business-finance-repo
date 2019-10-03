"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const connection_1 = require("./connection");
const wallet_helper_1 = require("./wallet-helper");
const constants_1 = require("../models/constants");
const firestore_service_1 = require("./firestore-service");
const stellar_service_1 = require("./stellar-service");
const z = "\n\n";
class TransactionServiceMultiple {
    static send(userName, functioName, jsonString) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            let start1 = new Date().getTime();
            try {
                const wallet = yield wallet_helper_1.WalletHelper.getAdminWallet();
                const contract = yield connection_1.ConnectToChaincode.connect(userName, wallet);
                console.log(`${z}🚀 🚀 🚀   submitting transaction to BFN ... functioName: ${functioName}`);
                const transaction = contract.createTransaction(functioName);
                start1 = new Date().getTime();
                let payload;
                const list = [];
                payload = yield transaction.submit(jsonString);
                const end = new Date().getTime();
                const elapsed4 = (end - start1) / 1000;
                console.log(`${z}⌛️ ⌛️ ⌛️  - ❤️  Contract execution took ${elapsed4} seconds `);
                console.log(`${z}☕️  ☕️  ☕️  ☕️  Payload: ${payload.toString()} ☕️  ☕️  ☕️  ☕️`);
                const response = JSON.parse(payload.toString());
                console.log(response);
                if (response.statusCode === 200) {
                    for (const m of response.result) {
                        yield this.writeToFirestore(functioName, JSON.stringify(m));
                    }
                    const end = new Date().getTime();
                    const elapsed4 = (end - start1) / 1000;
                    console.log(` ${z}⌛️ ⌛️ ⌛️ - ❤️  Contract execution + Firestore write took ${elapsed4} seconds:  😎 😎 😎  ${response.message}  ${z}`);
                }
                else {
                    console.log(` ${z}👿 👿 👿  contract execution fucked up in ${elapsed4} seconds: 😎 😎 😎 ${response.message}`);
                }
                return response;
            }
            catch (e) {
                const msg = `${z}👿 👿 👿 Error processing transaction, throwing my toys 👿👿👿${z} ${e} ${z}`;
                console.log(msg);
                throw new Error(msg);
            }
        });
    }
    static writeToFirestore(functioName, payload) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const start = new Date().getTime();
            switch (functioName) {
                case constants_1.Constants.CHAIN_ADD_COUNTRIES:
                    yield firestore_service_1.FirestoreService.writeCountry(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_USERS:
                    yield firestore_service_1.FirestoreService.writeUser(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_SECTORS:
                    yield firestore_service_1.FirestoreService.writeSector(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_CUSTOMERS:
                    yield stellar_service_1.StellarWalletService.createWallet(JSON.parse(payload).participantId);
                    yield firestore_service_1.FirestoreService.writeCustomer(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_SUPPLIERS:
                    yield stellar_service_1.StellarWalletService.createWallet(JSON.parse(payload).participantId);
                    yield firestore_service_1.FirestoreService.writeSupplier(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_INVESTORS:
                    yield stellar_service_1.StellarWalletService.createWallet(JSON.parse(payload).participantId);
                    yield firestore_service_1.FirestoreService.writeInvestor(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_PURCHASE_ORDERS:
                    yield firestore_service_1.FirestoreService.writePurchaseOrder(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_DELIVERY_NOTES:
                    yield firestore_service_1.FirestoreService.writeDeliveryNote(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_DELIVERY_NOTE_ACCEPTANCES:
                    yield firestore_service_1.FirestoreService.writeDeliveryAcceptance(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_INVOICES:
                    yield firestore_service_1.FirestoreService.writeInvoice(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_INVOICE_ACCEPTANCES:
                    yield firestore_service_1.FirestoreService.writeInvoiceAcceptance(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_OFFERS:
                    yield firestore_service_1.FirestoreService.writeOffer(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_INVESTOR_PROFILES:
                    yield firestore_service_1.FirestoreService.writeInvestorProfile(payload);
                    break;
                case constants_1.Constants.CHAIN_ADD_AUTOTRADE_ORDERS:
                    yield firestore_service_1.FirestoreService.writeAutoTradeOrder(payload);
                    break;
            }
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️ 🔵 🔵 🔵  Firestore ${functioName}; write took  ${elapsed4} seconds `);
        });
    }
}
exports.TransactionServiceMultiple = TransactionServiceMultiple;
/*

transaction-service.ts:24
🚀 🚀 🚀   submitting transaction to BFN ... functioName: addPurchaseOrder
(node:27877) UnhandledPromiseRejectionWarning: Error: No successful events received
warning.js:25
    at AllForTxStrategy.checkCompletion (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/fabric-network/lib/impl/event/allfortxstrategy.js:34:12)
    at AllForTxStrategy.errorReceived (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/fabric-network/lib/impl/event/abstracteventstrategy.js:67:8)
    at TransactionEventHandler._onError (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/fabric-network/lib/impl/event/transactioneventhandler.js:126:17)
    at EventRegistration.eventHub.registerTxEvent [as _onErrorFn] (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/fabric-network/lib/impl/event/transactioneventhandler.js:90:20)
    at EventRegistration.onError (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/fabric-network/node_modules/fabric-client/lib/ChannelEventHub.js:1570:9)
    at ChannelEventHub._closeAllCallbacks (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/fabric-network/node_modules/fabric-client/lib/ChannelEventHub.js:773:15)
    at ChannelEventHub._disconnect (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/fabric-network/node_modules/fabric-client/lib/ChannelEventHub.js:541:8)
    at ClientDuplexStream._stream.on (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/fabric-network/node_modules/fabric-client/lib/ChannelEventHub.js:491:10)
    at ClientDuplexStream.emit (events.js:197:13)
    at ClientDuplexStream._emitStatusIfDone (/Users/mac/Documents/GitHub/business-finance-network/bfnwebapi-node/node_modules/grpc/src/client.js:236:12)
(node:27877) UnhandledPromiseRejectionWarning: Unhandled promise rejection. This error originated either by throwing inside of an async function without a catch block, or by rejecting a promise which was not handled with .catch(). (rejection id: 1)
warning.js:25
(node:27877) [DEP0018] DeprecationWarning: Unhandled promise rejections are deprecated. In the future, promise rejections that are not handled will terminate the Node.js process with a non-zero exit code.
warning.js:25
transaction-service.ts:60
👿 👿 👿 Error processing transaction, throwing my toys 👿👿👿
 Error: No successful events received
server.ts:222
⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took 5.633 seconds
(node:27877) PromiseRejectionHandledWarning: Promise rejection was handled asynchronously (rejection id: 1)

////////////////////////
Failed to obtain Contract object : Error: Unable to initialize channel. Attempted to contact 1 Peers. Last error was Error: Failed to discover ::Error: Failed to connect before the deadline URL:grpcs://0616f307d3574967920019c6af5c6364-peer9d17d0.bfncluster.us-south.containers.appdomain.cloud:7051
transaction-service.ts:60

*/
//# sourceMappingURL=transaction-service.multiple.js.map