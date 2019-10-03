import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class AutoTradeStartHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.AutoTradeStart';

    public static async getAllAutoTradeStarts(ctx: Context): Promise<any> {
        console.info('💋 💋 AutoTradeStartHelper: getAllAutoTradeStarts .........\n\n');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }

    public static async createAutoTradeStart(ctx: Context, jsonString: string): Promise<any> {
        console.info('💋 💋 🙄 🙄 ### AutoTradeStartHelper: createAutoTradeStart\n');
        try {
            const jsonObj: any = JSON.parse(jsonString);
            jsonObj.autoTradeStartId = uuid();
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.dateStarted = new Date().toISOString();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.dateStarted]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.log(`💚 💚 💚 ### AutoTradeStartHelper: ${jsonObj.dateStarted} added to ledger 💚 💚 💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create AutoTradeStart failed: ${e}`);
        }
    }

}
