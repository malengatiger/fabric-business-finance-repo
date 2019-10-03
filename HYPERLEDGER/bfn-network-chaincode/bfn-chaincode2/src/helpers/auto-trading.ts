import { Context } from 'fabric-contract-api';
import { JsonConvert } from 'json2typescript';
import { AutoTradeOrder } from './models/auto-trade-order';
import { ExecutionUnit } from './models/execution-unit';
import { InvestorProfile } from './models/investor-profile';
import { Offer } from './models/offer';
import { Util } from './util';
const orders: AutoTradeOrder[] = [];
const profiles: InvestorProfile[] = [];
const offers: Offer[] = [];
const units: ExecutionUnit[] = [];
const autoTradeStart = {
    totalValidBids: 0,
    // tslint:disable-next-line:object-literal-sort-keys
    totalOffers: 0,
    totalInvalidBids: 0,
    possibleAmount: 0.0,
    totalAmount: 0.0,
    elapsedSeconds: 0.0,
    closedOffers: 0,
    dateStarted: new Date().toISOString(),
    dateEnded: null,
};
const OFFER_DOC_TYPE = 'com.oneconnect.biz.Offer';

export class AutoTrading {
    public static async start(ctx: Context) {
        console.log(`start AutoTrading ...`);
        await this.getData(ctx);
    }

    private static async getData(ctx: Context) {
        const iter: any = await ctx.stub.getStateByRange('startkey', 'endkey');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
            OFFER_DOC_TYPE,
            ['', ''],
        );
        const res = Util.getList(returnAsBytes);
        res.list.forEach((m) => {
            const jsonObj: any = JSON.parse(m);
            const jsonConvert: JsonConvert = new JsonConvert();
            const offer: Offer = jsonConvert.deserializeObject(jsonObj, Offer);
            if (offer.isOpen) {
                offers.push(offer);
            }
        });
        autoTradeStart.totalOffers = offers.length;
    }
}
