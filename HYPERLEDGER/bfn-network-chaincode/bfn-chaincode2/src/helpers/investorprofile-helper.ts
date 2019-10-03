import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class InvestorProfileHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.InvestorProfile';

    public static async getAllInvestorProfiles(ctx: Context): Promise<any> {
        console.info('😍 😍 InvestorProfileHelper getAllInvestorProfiles');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async createInvestorProfiles(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            let m;
            if (obj instanceof Object) {
                m = await this.createInvestorProfile(ctx, JSON.stringify(obj));
            } else {
                m = await this.createInvestorProfile(ctx, obj);
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
    public static async createInvestorProfile(ctx: Context, jsonString: string): Promise<any> {
        console.info('😍 😍 🙄 🙄 ### InvestorProfileHelper: createInvestorProfile\n');
        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.email) {
                return Util.sendError('missing email address');
            }
            if (!jsonObj.name) {
                return Util.sendError('missing name');
            }
            if (!jsonObj.investor) {
                return Util.sendError('missing investor');
            }

            jsonObj.profileId = uuid();
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.date = new Date().toISOString();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.investor, jsonObj.date]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚  ### InvestorProfileHelper: ${jsonObj.name} added to ledger 💚💚💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create InvestorProfile failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

}
