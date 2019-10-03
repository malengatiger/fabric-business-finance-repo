import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class DeliveryNoteHelper {
    public static DOC_TYPE_NOTE = 'com.oneconnect.biz.DeliveryNote';
    public static DOC_TYPE_ACCEPT = 'com.oneconnect.biz.DeliveryAcceptance';

    public static async getAllDeliveryNotes(ctx: Context): Promise<any> {
        console.info('💦 💦 DeliveryNoteHelper getAllDeliveryNotes');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_NOTE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async getAllDeliveryAcceptances(ctx: Context): Promise<any> {
        console.info('💦 💦 DeliveryNoteHelper getAllDeliveryAcceptances');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_ACCEPT, []);
        return await Util.getList(returnAsBytes);
    }
    public static async getDeliveryNotesByCustomer(ctx: Context, customer: string): Promise<any> {
        console.info('💦 💦 DeliveryNoteHelper: getDeliveryNotesByCustomer .........');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_NOTE, [customer]);
        return await Util.getList(returnAsBytes);
    }
    public static async getDeliveryNotesBySupplier(ctx: Context, supplier: string): Promise<any> {
        console.info('💦 💦 DeliveryNoteHelper: getDeliveryNotesBySupplier .........');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_NOTE, [supplier]);
        return await Util.getList(returnAsBytes);
    }
    public static async createDeliveryNotes(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createDeliveryNote(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }

    public static async createDeliveryNote(ctx: Context, jsonString: string): Promise<any> {
        console.info('💦 💦 ### DeliveryNoteHelper: createDeliveryNote 💦 \n');
        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.customer) {
                return Util.sendError('missing customer');
            }
            if (!jsonObj.supplier) {
                return Util.sendError('missing supplier');
            }
            if (!jsonObj.amount) {
                return Util.sendError('missing amount');
            }
            if (!jsonObj.purchaseOrder) {
                return Util.sendError('missing purchase order');
            }
            // todo check that purchase order exists ---
            jsonObj.deliveryNoteId = uuid();
            jsonObj.docType = this.DOC_TYPE_NOTE;
            jsonObj.date = new Date().toISOString();
            jsonObj.intDate = new Date().getTime();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE_NOTE,
                [jsonObj.supplier, jsonObj.customer, jsonObj.date]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            // tslint:disable-next-line:max-line-length
            console.info(`\n💚 💚 💚 ### DeliveryNoteHelper: 💦 createPO: ${jsonObj.supplierName} added to ledger 💚💚💚\n`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create DeliveryNote failed, jsonString: ${jsonString} ERROR: ${e}`);
        }

    }
    public static async acceptDeliveries(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.acceptDelivery(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async acceptDelivery(ctx: Context, jsonString: string): Promise<any> {
        console.info('💦 💦 ### DeliveryNoteHelper: acceptDelivery 💦 \n');
        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.customer) {
                return Util.sendError('missing customer');
            }
            if (!jsonObj.supplier) {
                return Util.sendError('missing supplier');
            }
            if (!jsonObj.deliveryNote) {
                return Util.sendError('missing amount');
            }
            if (!jsonObj.purchaseOrder) {
                return Util.sendError('missing purchase order');
            }

            // todo check that purchase order exists and that there are no other delivery notes ---
            jsonObj.acceptanceId = uuid();
            jsonObj.docType = this.DOC_TYPE_ACCEPT;
            jsonObj.date = new Date().toISOString();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE_ACCEPT,
                [jsonObj.customer, jsonObj.supplier, jsonObj.date]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            // tslint:disable-next-line:max-line-length
            console.info(`💚 💚 💚  ### DeliveryNoteHelper:  💦  acceptDelivery: ${jsonObj.supplierName} added to ledger 💚💚💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`acceptDelivery failed, jsonString: ${jsonString} ERROR: ${e}`);
        }

    }

}
