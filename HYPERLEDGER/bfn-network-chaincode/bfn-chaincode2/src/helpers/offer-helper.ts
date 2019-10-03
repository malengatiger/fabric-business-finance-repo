import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class OfferHelper {
    public static DOC_TYPE_OFFER = 'com.oneconnect.biz.Offer';

    public static async getAllOffers(ctx: Context): Promise<any> {
        console.info('😝 😝 OfferHelper getAllOffers');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_OFFER, []);
        return await Util.getList(returnAsBytes);
    }

    public static async getOffersBySupplier(ctx: Context, supplier: string): Promise<any> {
        console.info('😝 😝 OfferHelper: getOffersBySupplier .........');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_OFFER, [supplier]);
        return await Util.getList(returnAsBytes);
    }
    public static async createOffers(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createOffer(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createOffer(ctx: Context, jsonString: string): Promise<any> {
        console.info('😝 😝 💦 💦 ### OfferHelper: createOffer 💦 ');
        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.customer) {
                return Util.sendError('missing customer');
            }
            if (!jsonObj.supplier) {
                return Util.sendError('missing supplier');
            }
            if (!jsonObj.offerAmount) {
                return Util.sendError('missing offer amount');
            }
            if (!jsonObj.purchaseOrder) {
                return Util.sendError('missing purchase order');
            }
            if (!jsonObj.invoice) {
                return Util.sendError('missing invoice');
            }
            try {
                const offers = await this.getOffersByInvoice(ctx, [jsonObj.supplier, jsonObj.invoice]);
                if (offers.list.length > 0) {
                    // tslint:disable-next-line: max-line-length
                    return Util.sendError(`😡 Offer already exists for this invoice: 😡 ${jsonObj.invoice} ${jsonObj.customerName} from 💦 ${jsonObj.supplierName}`);
                }
            } catch (e) {
                console.error(`😡 😡 😡 😡 Error looking for existing offer for invoice: ${e}`);
            }
            jsonObj.offerId = uuid();
            jsonObj.docType = this.DOC_TYPE_OFFER;
            jsonObj.date = new Date().toISOString();
            jsonObj.intDate = new Date().getTime();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE_OFFER,
                [jsonObj.supplier, jsonObj.invoice, jsonObj.offerId]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            // tslint:disable-next-line:max-line-length
            console.info(`💚 💚 💚  ### OfferHelper: 💦 create offer: ${jsonObj.supplierName} added to ledger 💚💚💚`);
            const offers2 = await this.getOffersByInvoice(ctx, [jsonObj.supplier, jsonObj.invoice]);
            console.log(`invoice has offers: ${offers2.list.length}, error if greater than 1`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create Offer failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

    public static async cancelOffer(ctx: Context, jsonString: string): Promise<any> {
        const obj: any = JSON.parse(jsonString);
        try {
            const offer = await this.getOfferById(ctx, [obj.supplier, obj.invoice, obj.offerId]);
            offer.isCancelled = true;
            const key = ctx.stub.createCompositeKey(this.DOC_TYPE_OFFER,
                [obj.supplier, obj.invoice, obj.offerId]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(offer)));
            console.log(`offer has been cancelled. 😡 😡 😡 😡 ${offer}`);
            return Util.sendResult(offer);
        } catch (e) {
            return Util.sendError(`Cancel Offer failed: ${e}`);
        }
    }

    public static async closeOffer(ctx: Context, jsonString: string): Promise<any> {
        const obj: any = JSON.parse(jsonString);
        try {
            const offer = await this.getOfferById(ctx, [obj.supplier, obj.invoice, obj.offerId]);
            if (!offer) {
                return Util.sendError(`😡 Failed to find offer for closing: ${jsonString}`);
            }
            offer.isOpen = false;
            const key = ctx.stub.createCompositeKey(this.DOC_TYPE_OFFER,
                [obj.supplier, obj.invoice, obj.offerId]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(offer)));
            console.log(`❤️ offer has been closed. 😡 😡 😡 😡 ${offer}`);
            return Util.sendResult(offer);
        } catch (e) {
            return Util.sendError(`😡 😡 Close Offer failed: ${e}`);
        }
    }

    private static async getOfferById(ctx: Context, key: string[]): Promise<any> {
        const bytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_OFFER, key);
        // turn bytes into offer
        const offerList = Util.getList(bytes);
        if (offerList.list.length > 0) {
            return offerList.list[0];
        } else {
            return null;
        }
    }
    private static async getOffersByInvoice(ctx: Context, key: string[]): Promise<any> {
        const bytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_OFFER, key);
        // turn bytes into list of offers
        const offers = Util.getList(bytes);
        return offers;
    }
}
