"use strict";
// Uncomment following to enable zipkin tracing, tailor to fit your network configuration:
// var appzip = require('appmetrics-zipkin')({
//     host: 'localhost',
//     port: 9411,
//     serviceName:'frontend'
// });
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
// require('appmetrics-dash').attach();
// require('appmetrics-prometheus').attach();
// const appName = require('./../../package').name;
const appName = "bfnwebapinode";
const express_1 = tslib_1.__importDefault(require("express"));
const body_parser_1 = tslib_1.__importDefault(require("body-parser"));
const admin_registration_service_1 = require("./services/admin-registration-service");
const user_registration_service_1 = require("./services/user-registration-service");
const transaction_service_1 = require("./services/transaction-service");
const admin = tslib_1.__importStar(require("firebase-admin"));
const firestore_service_1 = require("./services/firestore-service");
const auto_trade_executor_1 = require("./services/auto_trade_executor");
const stellar_service_1 = require("./services/stellar-service");
const list_service_1 = require("./services/list-service");
/*
BUILD AND DEPLOY VIA CLOUD RUN
gcloud builds submit --tag gcr.io/business-finance-dev/bfnwebapi
gcloud beta run deploy --image gcr.io/business-finance-dev/bfnwebapi

RESULT:
Service [bfnwebapi] revision [bfnwebapi-00003] has been deployed and is serving traffic at https://bfnwebapi-hn3wjaywza-uc.a.run.app
*/
const fs = admin.firestore();
const http = require("http");
const log4js = require("log4js");
// const localConfig = require('./config/local.json');
const path = require("path");
const logger = log4js.getLogger("BFNWepAPI");
logger.level = process.env.LOG_LEVEL || "info";
const app = express_1.default();
const server = http.createServer(app);
app.use(body_parser_1.default.json());
app.use(body_parser_1.default.urlencoded({ extended: false }));
app.use(log4js.connectLogger(logger, { level: logger.level }));
const serviceManager = require("./services/service-manager");
require("./services/index")(app);
require("./routers/index")(app, server);
// Add your code here
app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With-Content-Type, Accept");
    next();
});
const port = process.env.PORT || 3001;
server.listen(port, function () {
    console.info(`\n\n🔵 🔵 🔵  -- BFNWebAPI started and listening on http://localhost:${port} 💦 💦 💦 💦`);
    console.info(`🙄 🙄 🙄  -- Application name:  💕 💕 💕 💕  BFNWepAPI running at: 💦 ${new Date().toISOString() + "  🙄 🙄 🙄"}`);
});
app.post("/executeAutoTrades", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.log(`💦 💦 💦 💦  Accepting command to start AutoTrades`);
        try {
            auto_trade_executor_1.AutoTradeExecutor.executeAutoTrades();
            console.log(`💦 💦 💦 💦  Immediate return after Accepting command to start AutoTrades`);
            res.status(200).json({
                message: "💕 💕  💕 💕 AutoTradeExecutor started ... 💕 💕  💕 💕 ",
            });
        }
        catch (e) {
            res.status(400).json({
                message: "😈 😈 😈 😈 Error running AutoTradeExecutor",
                error: e
            });
        }
    });
});
app.post("/createStellarWallet", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.log(`💦 💦 💦 💦  Accepting command to start createStellarWallet`);
        console.log(`🙄 request participantId: ${req.body.participantId}`);
        try {
            const participantId = req.body.participantId;
            const result = yield stellar_service_1.StellarWalletService.createWallet(participantId);
            res.status(200).json({
                message: "💕 💕  💕 💕 Stellar wallet created OK  💕 💕  💕 💕 ",
                result: result
            });
        }
        catch (e) {
            res.status(400).json({
                message: "😈 😈 😈 😈 Error creating Stellar wallet",
                error: e
            });
        }
    });
});
// Administrator Route
app.get("/enrollAdmin", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.log(`\n🙄 🙄 🙄 🙄 🙄    --- enrollAdmin `);
        let result;
        try {
            result = yield admin_registration_service_1.AdminRegistrationSevice.enrollAdmin();
            res.status(200).json({
                message: " 💕 💕  💕 💕  Enroll Admin complete!  💙  💚  💛 💙  💚  💛",
                result: result
            });
        }
        catch (e) {
            res.status(400).json({
                message: "👿 👿 👿 👿  Enroll Admin failed!  👿 👿 👿 👿",
                error: e
            });
        }
    });
});
app.get("/ping", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.log(`🙄 🙄 🙄 🙄 🙄 --- 💦 ping 💦--- 🙄 🙄 🙄 🙄 🙄 `);
        const date = new Date().toISOString();
        const pingData = {
            date: date,
            from: req.url,
            originalUrl: req.originalUrl,
        };
        const ref = yield fs.collection('testPings').add(pingData);
        console.log('🎉 🎉 🎉  ping record written to 💙 Firestore');
        res.status(200).json({
            message: " 💕 💕  💕 💕  BFNWebAPI pinged!  💙  💚  💛 💙  💚  💛",
            result: `🔵  🔵  🔵  Everything\'s cool. 💦 💦 The path to BFN chaincode begins right here: 💛 ${date} 💦 💦`,
            path: ref.path,
            ping: pingData
        });
    });
});
//
app.get("/enrollUser", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.log(`🙄 request userName: ${req.query.userName}`);
        const userName = req.query.userName;
        if (!userName) {
            res.status(400).json({
                message: "😡 😡 😡 😡  missing userName  👿 👿 👿 👿"
            });
            return;
        }
        let result;
        try {
            result = yield user_registration_service_1.UserRegistrationSevice.enrollUser(userName);
            res.status(200).json({
                message: `💕 💕  💕 💕  Enroll ${userName} complete!  💙  💚  💛 💙  💚  💛`,
                result: result
            });
        }
        catch (e) {
            res.status(400).json({
                message: `👿 👿 👿 👿  Enroll  ${userName} failed!  👿 👿 👿 👿`,
                error: e
            });
        }
    });
});
app.post("/fixCountries", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.log(`\n🙄 😪 😪 😪 fixCountries request body strings: ${req.body.strings}`);
        const strings = req.body.strings;
        try {
            yield firestore_service_1.FirestoreService.fixCountries(strings);
            res.status(200).json({
                message: `💕 💕  💕 💕  FirestoreService.fixCountries complete!  💙  💚  💛 💙  💚  💛`
            });
        }
        catch (e) {
            res.status(400).json({
                message: `👿 👿 👿 👿  Country FIX failed!  👿 👿 👿 👿`,
                error: e
            });
        }
    });
});
app.post("/sendTransaction", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.info(`🙄 👿  sendTransaction request body userName:  🅿️ ${req.body.userName}`);
        console.info(`🙄 👿  sendTransaction request body functionName:  🅿️ ${req.body.functionName}`);
        console.info(`🙄 👿  sendTransaction request body jsonString:  🅿️  🅿️  🅿️ ${req.body.jsonString}\n\n`);
        const userName = req.body.userName;
        const functionName = req.body.functionName;
        const jsonString = req.body.jsonString;
        if (!functionName) {
            res.status(400).json({
                message: "😡 😡 😡 😡  missing functionName   👿 👿 👿 👿"
            });
            return;
        }
        if (!userName) {
            res.status(400).json({
                message: "😡 😡 😡 😡  missing userName   👿 👿 👿 👿"
            });
            return;
        }
        const start = new Date().getTime();
        try {
            let result;
            result = yield transaction_service_1.TransactionService.send(userName, functionName, jsonString);
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️  💕 💕 💕 💕 getting everything done took  ⌛️ ${elapsed4} seconds  💕 💕 💕 💕 💕 💕 💕 💕 \n`);
            res.status(result.statusCode).json(result);
        }
        catch (e) {
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `);
            res.status(400).json({
                message: `👿 👿 👿 👿  Transaction Request failed   👿 👿 👿 👿`,
                error: e
            });
        }
    });
});
app.post("/sendTransactions", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.info(`🙄  sendTransaction request body userName:  🅿️ ${req.body.userName}`);
        console.info(`🙄 👿  sendTransaction request body functionName:  🅿️ ${req.body.functionName}`);
        console.info(`🙄 👿  sendTransaction request body jsonString:  🅿️  🅿️  🅿️ ${req.body.jsonString}\n\n`);
        const userName = req.body.userName;
        const functionName = req.body.functionName;
        const jsonString = req.body.jsonString;
        if (!functionName) {
            res.status(400).json({
                message: "😡 😡 😡 😡  missing functionName   👿 👿 👿 👿"
            });
            return;
        }
        if (!userName) {
            res.status(400).json({
                message: "😡 😡 😡 😡  missing userName   👿 👿 👿 👿"
            });
            return;
        }
        const start = new Date().getTime();
        try {
            let result;
            result = yield transaction_service_1.TransactionService.send(userName, functionName, jsonString);
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️  💕 💕 getting everything done took  ⌛️ ${elapsed4} seconds \n`);
            res.status(result.statusCode).json(result);
        }
        catch (e) {
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `);
            res.status(400).json({
                message: `👿 👿 👿 👿  Transaction Request failed   👿 👿 👿 👿`,
                error: e
            });
        }
    });
});
app.post("/getCustomerDashboard", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.info(`🙄 getCustomerDashboard request body customer participantId:  🅿️ ${req.body.participantId}`);
        const participantId = req.body.participantId;
        if (!participantId) {
            res.status(400).json({
                message: "😡 😡 😡 😡  missing participantId   👿 👿 👿 👿"
            });
            return;
        }
        const start = new Date().getTime();
        try {
            let result;
            result = yield list_service_1.ListService.getCustomerDashboard(participantId);
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️  💕 💕 getting everything listed took  ⌛️ ${elapsed4} seconds \n`);
            res.status(200).json(result);
        }
        catch (e) {
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `);
            res.status(400).json({
                message: `👿 👿 👿 👿  getCustomerDashboard failed   👿 👿 👿 👿`,
                error: e
            });
        }
    });
});
app.post("/getSupplierDashboard", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.info(`🙄 getSupplierDashboard request body supplier participantId:  🅿️ ${req.body.participantId}`);
        const participantId = req.body.participantId;
        if (!participantId) {
            res.status(400).json({
                message: "😡 😡 😡 😡  missing participantId   👿 👿 👿 👿"
            });
            return;
        }
        const start = new Date().getTime();
        try {
            let result;
            result = yield list_service_1.ListService.getSupplierDashboard(participantId);
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️  💕 💕 getting everything listed took  ⌛️ ${elapsed4} seconds \n\n`);
            res.status(200).json(result);
        }
        catch (e) {
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `);
            res.status(400).json({
                message: `👿 👿 👿 👿  getSupplierDashboard failed   👿 👿 👿 👿`,
                error: e
            });
        }
    });
});
app.post("/getInvestorDashboard", function (req, res) {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        console.info(`🙄  getInvestorDashboard request body investor participantId:  🅿️ ${req.body.participantId}`);
        const participantId = req.body.participantId;
        if (!participantId) {
            res.status(400).json({
                message: "😡 😡 😡 😡  missing participantId   👿 👿 👿 👿"
            });
            return;
        }
        const start = new Date().getTime();
        try {
            let result;
            result = yield list_service_1.ListService.getInvestorDashboard(participantId);
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️  💕 💕 getting everything listed took  ⌛️ ${elapsed4} seconds \n\n`);
            res.status(200).json(result);
        }
        catch (e) {
            const end = new Date().getTime();
            const elapsed4 = (end - start) / 1000;
            console.log(`⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `);
            res.status(400).json({
                message: `👿 👿 👿 👿  getSupplierDashboard failed   👿 👿 👿 👿`,
                error: e
            });
        }
    });
});
//
app.use(function (req, res, next) {
    res.sendFile(path.join(__dirname, "../../public", "404.html"));
});
app.use(function (err, req, res, next) {
    res.sendFile(path.join(__dirname, "../../public", "500.html"));
});
module.exports = server;
//# sourceMappingURL=server.js.map