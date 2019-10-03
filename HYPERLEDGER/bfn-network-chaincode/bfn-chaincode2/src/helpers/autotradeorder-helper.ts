import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class AutoTradeOrderHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.AutoTradeOrder';

    public static async getAllAutoTradeOrders(ctx: Context): Promise<any> {
        console.info('💋 💋 AutoTradeOrderHelper: getAllAutoTradeOrders .........\n\n');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async createAutoTradeOrders(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            let m;
            if (obj instanceof Object) {
                m = await this.createAutoTradeOrder(ctx, JSON.stringify(obj));
            } else {
                m = await this.createAutoTradeOrder(ctx, obj);
            }
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createAutoTradeOrder(ctx: Context, jsonString: string): Promise<any> {
        console.info('💋 💋 🙄 🙄 ### AutoTradeOrderHelper: createAutoTradeOrder\n');

        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.investor) {
                return Util.sendError('missing investor');
            }
            if (!jsonObj.investorName) {
                return Util.sendError('missing investorName');
            }
            if (!jsonObj.investorProfile) {
                return Util.sendError('missing investor profile');
            }

            jsonObj.autoTradeOrderId = uuid();
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.date = new Date().toISOString();
            jsonObj.isCancelled = false;

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.investor, jsonObj.date]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚 ### AutoTradeOrderHelper: ${jsonObj.name} added to ledger 💚 💚 💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create AutoTradeOrder failed: ${e}`);
        }
    }

}
