// Uncomment following to enable zipkin tracing, tailor to fit your network configuration:
// var appzip = require('appmetrics-zipkin')({
//     host: 'localhost',
//     port: 9411,
//     serviceName:'frontend'
// });

// require('appmetrics-dash').attach();
// require('appmetrics-prometheus').attach();
// const appName = require('./../../package').name;
const appName = "bfnwebapinode";
import express from "express";
import { Request, Response, NextFunction } from "express";
import bodyParser from "body-parser";
import { AdminRegistrationSevice } from "./services/admin-registration-service";
import { UserRegistrationSevice } from "./services/user-registration-service";
import { TransactionService } from "./services/transaction-service";
import * as admin from "firebase-admin";
import { Firestore } from "@google-cloud/firestore";
import { FirestoreService } from "./services/firestore-service";
import { AutoTradeExecutor } from "./services/auto_trade_executor";
import { StellarWalletService } from './services/stellar-service';
import { ListService } from './services/list-service';
/*
BUILD AND DEPLOY VIA CLOUD RUN
gcloud builds submit --tag gcr.io/business-finance-dev/bfnwebapi
gcloud beta run deploy --image gcr.io/business-finance-dev/bfnwebapi

RESULT:
Service [bfnwebapi] revision [bfnwebapi-00003] has been deployed and is serving traffic at https://bfnwebapi-hn3wjaywza-uc.a.run.app
*/
const fs: Firestore = admin.firestore();
const http = require("http");
const log4js = require("log4js");
// const localConfig = require('./config/local.json');
const path = require("path");

const logger = log4js.getLogger("BFNWepAPI");
logger.level = process.env.LOG_LEVEL || "info";
const app = express();
const server = http.createServer(app);
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use(log4js.connectLogger(logger, { level: logger.level }));
const serviceManager = require("./services/service-manager");
require("./services/index")(app);
require("./routers/index")(app, server);

// Add your code here
app.use(function (req: Request, res: Response, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With-Content-Type, Accept"
  );
  next();
});

const port = process.env.PORT || 3001;
server.listen(port, function () {

  console.info(
    `\n\n🔵 🔵 🔵  -- BFNWebAPI started and listening on http://localhost:${port} 💦 💦 💦 💦`
  );
  console.info(
    `🙄 🙄 🙄  -- Application name:  💕 💕 💕 💕  BFNWepAPI running at: 💦 ${new Date().toISOString() + "  🙄 🙄 🙄"}`
  );
});

app.post("/executeAutoTrades", async function (req: Request, res: Response) {
  console.log(`💦 💦 💦 💦  Accepting command to start AutoTrades`)
  try {
    AutoTradeExecutor.executeAutoTrades();
    console.log(`💦 💦 💦 💦  Immediate return after Accepting command to start AutoTrades`)
    res.status(200).json({
      message: "💕 💕  💕 💕 AutoTradeExecutor started ... 💕 💕  💕 💕 ",
    });
  } catch (e) {
    res.status(400).json({
      message: "😈 😈 😈 😈 Error running AutoTradeExecutor",
      error: e
    });
  }
});
app.post("/createStellarWallet", async function (req: Request, res: Response) {
  console.log(`💦 💦 💦 💦  Accepting command to start createStellarWallet`)
  console.log(`🙄 request participantId: ${req.body.participantId}`);

  try {
    const participantId: string = req.body.participantId
    const result = await StellarWalletService.createWallet(participantId);
    res.status(200).json({
      message: "💕 💕  💕 💕 Stellar wallet created OK  💕 💕  💕 💕 ",
      result: result
    });
  } catch (e) {
    res.status(400).json({
      message: "😈 😈 😈 😈 Error creating Stellar wallet",
      error: e
    });
  }
});
// Administrator Route
app.get("/enrollAdmin", async function (req: Request, res: Response) {
  console.log(`\n🙄 🙄 🙄 🙄 🙄    --- enrollAdmin `);

  let result;
  try {
    result = await AdminRegistrationSevice.enrollAdmin();
    res.status(200).json({
      message: " 💕 💕  💕 💕  Enroll Admin complete!  💙  💚  💛 💙  💚  💛",
      result: result
    });
  } catch (e) {
    res.status(400).json({
      message: "👿 👿 👿 👿  Enroll Admin failed!  👿 👿 👿 👿",
      error: e
    });
  }
});
app.get("/ping", async function (req: Request, res: Response) {

  console.log(`🙄 🙄 🙄 🙄 🙄 --- 💦 ping 💦--- 🙄 🙄 🙄 🙄 🙄 `);

  const date = new Date().toISOString();
  const pingData = {
    date: date,
    from: req.url,
    originalUrl: req.originalUrl,
  }
  const ref = await fs.collection('testPings').add(pingData);
  console.log('🎉 🎉 🎉  ping record written to 💙 Firestore')
  res.status(200).json({
    message: " 💕 💕  💕 💕  BFNWebAPI pinged!  💙  💚  💛 💙  💚  💛",
    result: `🔵  🔵  🔵  Everything\'s cool. 💦 💦 The path to BFN chaincode begins right here: 💛 ${date} 💦 💦`,
    path: ref.path,
    ping: pingData
  });
});
//
app.get("/enrollUser", async function (req: Request, res: Response) {
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
    result = await UserRegistrationSevice.enrollUser(userName);
    res.status(200).json({
      message: `💕 💕  💕 💕  Enroll ${userName} complete!  💙  💚  💛 💙  💚  💛`,
      result: result
    });
  } catch (e) {
    res.status(400).json({
      message: `👿 👿 👿 👿  Enroll  ${userName} failed!  👿 👿 👿 👿`,
      error: e
    });
  }
});
app.post("/fixCountries", async function (req: Request, res: Response) {
  console.log(
    `\n🙄 😪 😪 😪 fixCountries request body strings: ${req.body.strings}`
  );

  const strings = req.body.strings;
  try {
    await FirestoreService.fixCountries(strings);
    res.status(200).json({
      message: `💕 💕  💕 💕  FirestoreService.fixCountries complete!  💙  💚  💛 💙  💚  💛`
    });
  } catch (e) {
    res.status(400).json({
      message: `👿 👿 👿 👿  Country FIX failed!  👿 👿 👿 👿`,
      error: e
    });
  }
});
app.post("/sendTransaction", async function (req: Request, res: Response) {
  console.info(
    `🙄 👿  sendTransaction request body userName:  🅿️ ${req.body.userName}`
  );
  console.info(
    `🙄 👿  sendTransaction request body functionName:  🅿️ ${
    req.body.functionName
    }`
  );
  console.info(
    `🙄 👿  sendTransaction request body jsonString:  🅿️  🅿️  🅿️ ${req.body.jsonString}\n\n`
  );

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
    let result: any;
    result = await TransactionService.send(userName, functionName, jsonString);
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️  💕 💕 💕 💕 getting everything done took  ⌛️ ${elapsed4} seconds  💕 💕 💕 💕 💕 💕 💕 💕 \n`
    );

    res.status(result.statusCode).json(result);

  } catch (e) {
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `
    );
    res.status(400).json({
      message: `👿 👿 👿 👿  Transaction Request failed   👿 👿 👿 👿`,
      error: e
    });
  }
});
app.post("/sendTransactions", async function (req: Request, res: Response) {
  console.info(
    `🙄  sendTransaction request body userName:  🅿️ ${req.body.userName}`
  );
  console.info(
    `🙄 👿  sendTransaction request body functionName:  🅿️ ${
    req.body.functionName
    }`
  );
  console.info(
    `🙄 👿  sendTransaction request body jsonString:  🅿️  🅿️  🅿️ ${req.body.jsonString}\n\n`
  );

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
    let result: any;
    result = await TransactionService.send(userName, functionName, jsonString);
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️  💕 💕 getting everything done took  ⌛️ ${elapsed4} seconds \n`
    );

    res.status(result.statusCode).json(result);

  } catch (e) {
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `
    );
    res.status(400).json({
      message: `👿 👿 👿 👿  Transaction Request failed   👿 👿 👿 👿`,
      error: e
    });
  }
});
app.post("/getCustomerDashboard", async function (req: Request, res: Response) {
  console.info(
    `🙄 getCustomerDashboard request body customer participantId:  🅿️ ${req.body.participantId}`
  );
  const participantId = req.body.participantId;
  if (!participantId) {
    res.status(400).json({
      message: "😡 😡 😡 😡  missing participantId   👿 👿 👿 👿"
    });
    return;
  }
  const start = new Date().getTime();
  try {
    let result: any;
    result = await ListService.getCustomerDashboard(participantId);
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️  💕 💕 getting everything listed took  ⌛️ ${elapsed4} seconds \n`
    );
    res.status(200).json(result);
  } catch (e) {
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `
    );
    res.status(400).json({
      message: `👿 👿 👿 👿  getCustomerDashboard failed   👿 👿 👿 👿`,
      error: e
    });
  }
});
app.post("/getSupplierDashboard", async function (req: Request, res: Response) {
  console.info(
    `🙄 getSupplierDashboard request body supplier participantId:  🅿️ ${req.body.participantId}`
  );
  const participantId = req.body.participantId;
  if (!participantId) {
    res.status(400).json({
      message: "😡 😡 😡 😡  missing participantId   👿 👿 👿 👿"
    });
    return;
  }
  const start = new Date().getTime();
  try {
    let result: any;
    result = await ListService.getSupplierDashboard(participantId);
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️  💕 💕 getting everything listed took  ⌛️ ${elapsed4} seconds \n\n`
    );
    res.status(200).json(result);
  } catch (e) {
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `
    );
    res.status(400).json({
      message: `👿 👿 👿 👿  getSupplierDashboard failed   👿 👿 👿 👿`,
      error: e
    });
  }
});
app.post("/getInvestorDashboard", async function (req: Request, res: Response) {
  console.info(
    `🙄  getInvestorDashboard request body investor participantId:  🅿️ ${req.body.participantId}`
  );
  const participantId = req.body.participantId;
  if (!participantId) {
    res.status(400).json({
      message: "😡 😡 😡 😡  missing participantId   👿 👿 👿 👿"
    });
    return;
  }
  const start = new Date().getTime();
  try {
    let result: any;
    result = await ListService.getInvestorDashboard(participantId);
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️  💕 💕 getting everything listed took  ⌛️ ${elapsed4} seconds \n\n`
    );
    res.status(200).json(result);
  } catch (e) {
    const end = new Date().getTime();
    const elapsed4 = (end - start) / 1000;
    console.log(
      `⌛️ ⌛️ ⌛️   👿 👿 👿  getting everything fucked up took ${elapsed4} seconds `
    );
    res.status(400).json({
      message: `👿 👿 👿 👿  getSupplierDashboard failed   👿 👿 👿 👿`,
      error: e
    });
  }
});
//
app.use(function (req: Request, res: Response, next: NextFunction) {
  res.sendFile(path.join(__dirname, "../../public", "404.html"));
});

app.use(function (err: Error, req: Request, res: Response, next: NextFunction) {
  res.sendFile(path.join(__dirname, "../../public", "500.html"));
});

module.exports = server;
