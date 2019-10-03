"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const investor_profile_1 = require("../models/investor-profile");
const execution_unit_1 = require("../models/execution-unit");
const invalid_summary_1 = require("../models/invalid-summary");
class Matcher {
    static match(profiles, orders, offers) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            console.info('\n\n🙄 🙄 🙄 🙄 ## Matcher : start matching ............ 🙄 🙄 🙄 🙄');
            const units = [];
            let pOffers = offers;
            let loopCount = 0;
            const MAX_LOOPS = 1;
            const MAX_UNITS = 5;
            const invalidSummary = new invalid_summary_1.InvalidSummary();
            invalidSummary.date = new Date().toISOString();
            let start;
            let end;
            let orderIndex = 0;
            let offerIndex = 0;
            console.info('🙄 🙄 🙄 🙄  getting each profiles total existing bids ...');
            for (const prof of profiles) {
                yield getInvestorBidTotal(prof);
            }
            shuffleOrders();
            yield initializeLoop();
            console.info('🔵 🔵 🔵  initializeLoop: Returning execution units to caller, units: ' +
                units.length);
            return units;
            function initializeLoop() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.info('💦  💦  💦  initializeLoop: loopCount: ' +
                        loopCount +
                        ' units: ' +
                        units.length +
                        ' offers outstanding: ' +
                        pOffers.length);
                    orderIndex = 0;
                    offerIndex = 0;
                    if (units.length === MAX_UNITS || units.length > MAX_UNITS) {
                        return units;
                    }
                    yield control();
                    // create new offer list without the offers already taken
                    const tempOffers = [];
                    for (const off of offers) {
                        let isFound = false;
                        for (const unit of units) {
                            if (off.offerId === unit.offer.offerId) {
                                isFound = true;
                            }
                        }
                        if (!isFound) {
                            tempOffers.push(off);
                        }
                    }
                    pOffers = tempOffers;
                    loopCount++;
                    console.info('🙄 🙄 🙄 🙄 loop complete, next loop is: ' +
                        loopCount +
                        ' MAX_LOOPS: ' +
                        MAX_LOOPS);
                    if (invalidSummary.invalidTrades > 0) {
                        if (loopCount < MAX_LOOPS) {
                            shuffleOrders();
                            yield initializeLoop();
                        }
                    }
                    console.info('💙  💚  💛 💙  💚  💛 MATCHING COMPLETE:  units: see invalidSummary above ...');
                    console.info(invalidSummary);
                    return units;
                });
            }
            function control() {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    if (units.length === MAX_UNITS || units.length > MAX_UNITS) {
                        return null;
                    }
                    console.log(`🤖🤖 running control ....`);
                    if (offerIndex === pOffers.length) {
                        return null;
                    }
                    if (orderIndex < orders.length) {
                        const isValid = yield findInvestorMatch(pOffers[offerIndex], orders[orderIndex]);
                        if (isValid) {
                            orderIndex++;
                            offerIndex++;
                            yield control();
                        }
                        else {
                            orderIndex++;
                            yield control();
                        }
                    }
                    else {
                        orderIndex = 0;
                        offerIndex++;
                        if (offerIndex === pOffers.length) {
                            return null;
                        }
                        yield control();
                    }
                    return null;
                });
            }
            function findInvestorMatch(mOffer, mOrder) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    console.log(`🔵  🔵 finding investor / offer match ...`);
                    let profile = new investor_profile_1.InvestorProfile();
                    profiles.forEach((p) => {
                        if (mOrder.investorProfile ===
                            p.profileId) {
                            profile = p;
                        }
                    });
                    if (profile.profileId === null) {
                        console.info(`😡 😡  profile is NULL for ${mOrder.investorName}`);
                        return false;
                    }
                    start = new Date().getTime();
                    const isValidBid = yield validate(profile, mOffer);
                    end = new Date().getTime();
                    if (isValidBid) {
                        const unit = new execution_unit_1.ExecutionUnit();
                        unit.offer = mOffer;
                        unit.profile = profile;
                        unit.order = mOrder;
                        units.push(unit);
                        invalidSummary.totalUnits++;
                        profile.totalBidAmount += mOffer.offerAmount;
                        console.info(`💙 💙 ## valid execution unit created, units: ${units.length}, added for ${unit.profile.name}, amt: ${unit.offer.offerAmount}  💙 💙 `);
                        return isValidBid;
                    }
                    else {
                        invalidSummary.invalidTrades++;
                    }
                    return false;
                });
            }
            function validate(profile, offer) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    if (profile === null) {
                        return false;
                    }
                    let isValidTotal = false;
                    const isValidSupplier = isWithinSupplierList(profile, offer);
                    const isValidSector = isWithinSectorList(profile, offer);
                    const isValidAccountBalance = yield isAccountBalanceOK(profile);
                    let isValidInvoiceAmount = false;
                    let isValidMinimumDiscount = false;
                    const mTotal = profile.totalBidAmount + offer.offerAmount;
                    if (mTotal < profile.maxInvestableAmount ||
                        mTotal === profile.maxInvestableAmount) {
                        isValidTotal = true;
                    }
                    else {
                        invalidSummary.isValidInvestorMax++;
                    }
                    if (offer.discountPercent > profile.minimumDiscount ||
                        offer.discountPercent === profile.minimumDiscount) {
                        isValidMinimumDiscount = true;
                    }
                    else {
                        invalidSummary.isValidMinimumDiscount++;
                    }
                    if (offer.offerAmount < profile.maxInvoiceAmount ||
                        offer.offerAmount === profile.maxInvoiceAmount) {
                        isValidInvoiceAmount = true;
                    }
                    else {
                        invalidSummary.isValidInvoiceAmount++;
                    }
                    if (isValidTotal &&
                        isValidSupplier &&
                        isValidSector &&
                        isValidInvoiceAmount &&
                        isValidMinimumDiscount &&
                        isValidAccountBalance) {
                        return true;
                    }
                    else {
                        return false;
                    }
                });
            }
            function getInvestorBidTotal(profile) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    //   let querySnap;
                    //   querySnap = await admin
                    //     .firestore()
                    //     .collection("investors")
                    //     .where("participantId", "==", profile.investor.split("#")[1])
                    //     .get();
                    //   if (querySnap.docs.length > 0) {
                    //     const investorRef = querySnap.docs[0].ref;
                    //     let bidQuerySnap;
                    //     bidQuerySnap = await investorRef
                    //       .collection("invoiceBids")
                    //       .where("isSettled", "==", false)
                    //       .get();
                    //     if (bidQuerySnap.docs.length === 0) {
                    //       return true;
                    //     } else {
                    //       let total = 0.0;
                    //       bidQuerySnap.forEach(doc => {
                    //         const bid = doc.data();
                    //         total += bid.amount;
                    //       });
                    //       profile.totalBidAmount = total;
                    //     }
                    //   }
                    //   await sendMessageToHeartbeatTopic(
                    //     `completed trade data aggregation for investor existing bids: ${
                    //       profile.name
                    //     }`
                    //   );
                    //   console.info(
                    //     "Total existing bid amount: " +
                    //       profile.totalBidAmount +
                    //       " for " +
                    //       profile.name
                    //   );
                    return true;
                });
            }
            function isWithinSupplierList(profile, offer) {
                try {
                    if (profile === null) {
                        return true;
                    }
                    if (!profile.suppliers) {
                        return true;
                    }
                    if (profile.suppliers.length === 0) {
                        return true;
                    }
                    let isSupplierOK = false;
                    profile.suppliers.forEach((supplier) => {
                        if (offer.supplier ===
                            supplier) {
                            isSupplierOK = true;
                        }
                    });
                    if (!isSupplierOK) {
                        invalidSummary.isValidSupplier++;
                    }
                    return isSupplierOK;
                }
                catch (e) {
                    console.info(e);
                    console.info(`FAILED: supplier validation - for ${offer.supplierName} ${offer.offerAmount}`);
                    return true;
                }
            }
            function isWithinSectorList(profile, offer) {
                try {
                    if (profile === null) {
                        return true;
                    }
                    if (!profile.sectors) {
                        return true;
                    }
                    if (profile.sectors.length === 0) {
                        return true;
                    }
                    let isSectorOK = false;
                    profile.sectors.forEach((sector) => {
                        if (offer.sector ===
                            sector) {
                            isSectorOK = true;
                        }
                    });
                    if (!isSectorOK) {
                        invalidSummary.isValidSector++;
                    }
                    return isSectorOK;
                }
                catch (e) {
                    console.info(e);
                    console.info(`FAILED: sector validation for ${offer.supplierName} ${offer.offerAmount}`);
                    return true;
                }
            }
            function isAccountBalanceOK(profile) {
                return tslib_1.__awaiter(this, void 0, void 0, function* () {
                    // TODO - connect to Stellar/WorldWire here
                    return true;
                });
            }
            // function shuffleProfiles() {
            //   for (let i = profiles.length - 1; i > 0; i--) {
            //     const j = Math.floor(Math.random() * (i + 1));
            //     [profiles[i], profiles[j]] = [profiles[j], profiles[i]];
            //   }
            // }
            // function shuffleOffers() {
            //   for (let i = offers.length - 1; i > 0; i--) {
            //     const j = Math.floor(Math.random() * (i + 1));
            //     [offers[i], offers[j]] = [offers[j], offers[i]];
            //   }
            //   console.info("########## shuffled offers ........");
            // }
            function shuffleOrders() {
                for (let i = orders.length - 1; i > 0; i--) {
                    const j = Math.floor(Math.random() * (i + 1));
                    [orders[i], orders[j]] = [orders[j], orders[i]];
                }
                console.info('💙 🙄 🙄 🙄  shuffled orders ........');
            }
        });
    }
}
exports.Matcher = Matcher;
//# sourceMappingURL=matcher.js.map