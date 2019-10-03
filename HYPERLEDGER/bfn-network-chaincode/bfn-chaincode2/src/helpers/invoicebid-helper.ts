import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { OfferHelper } from './offer-helper';
import { Util } from './util';

export class InvoiceBidHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.InvoiceBid';

    public static async getAllInvoiceBids(ctx: Context): Promise<any> {
        console.info('☕️ ☕️ ☕️  InvoiceBidHelper getAllInvoiceBids');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async getInvoiceBidsByInvestor(ctx: Context, investor: string): Promise<any> {
        console.info('☕️ ☕️ ☕️   InvoiceBidHelper: getInvoiceBidsByInvestor .........');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, [investor]);
        return await Util.getList(returnAsBytes);
    }
    public static async getInvoiceBidsBySupplier(ctx: Context, supplier: string): Promise<any> {
        console.info('☕️ ☕️ ☕️   InvoiceBidHelper: getInvoiceBidsBySupplier .........');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, ['', supplier]);
        return await Util.getList(returnAsBytes);
    }
    public static async getInvoiceBidsByOffer(ctx: Context,
        supplier: string, investor: string, offer: string): Promise<any> {
        console.info('☕️ ☕️ ☕️   InvoiceBidHelper: getInvoiceBidsByOffer .........');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
            this.DOC_TYPE, [investor, supplier, offer]);
        return await Util.getList(returnAsBytes);
    }

    public static async createInvoiceBid(ctx: Context, jsonString: string): Promise<any> {
        console.info('☕️ ☕️ ☕️   ### InvoiceBidHelper: createInvoiceBid 💦 \n');

        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.reservePercent) {
                return Util.sendError('missing reservePercent');
            }
            if (!jsonObj.supplier) {
                return Util.sendError('missing supplier');
            }
            if (!jsonObj.amount) {
                return Util.sendError('missing amount');
            }
            if (!jsonObj.offer) {
                return Util.sendError('missing offer');
            }
            if (!jsonObj.invoice) {
                return Util.sendError('missing invoice');
            }
            // todo check stuff ... ---
            const m = await this.getInvoiceBidsByOffer(
                ctx, jsonObj.supplier, jsonObj.investor, jsonObj.offer);
            if (m.list.length > 0) {
                jsonObj.multipleBid = m.list.length;
            }
            jsonObj.invoiceBidId = uuid();
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.date = new Date().toISOString();
            jsonObj.intDate = new Date().getTime();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE,
                [jsonObj.investor, jsonObj.supplier, jsonObj.offer, jsonObj.date]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            // tslint:disable-next-line:max-line-length
            console.info(`💚 💚 💚 ### InvoiceBidHelper: 💦 create bid: ${jsonObj.supplierName} added to ledger 💚💚💚`);
            if (jsonObj.reservePercent === 100) {
                jsonObj.offerId = jsonObj.offer;
                try {
                    await OfferHelper.closeOffer(ctx, JSON.stringify(jsonObj));
                } catch (e) {
                    return Util.sendError(`Failed to close Offer after 100% bid.  😡 ${jsonObj.offerId}`);
                }
            }
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create InvoiceBid failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

}
