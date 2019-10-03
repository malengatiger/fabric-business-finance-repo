import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Investor } from './models/investor';
import { Util } from './util';

export class InvestorHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.Investor';

    public static async getAllInvestors(ctx: Context): Promise<any> {
        console.info('😍 😍 InvestorHelper getAllInvestors');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async getCountryInvestors(ctx: Context, countryCode: string): Promise<any> {
        console.info('😍 😍  InvestorHelper: getCountryInvestors .........');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, [countryCode]);
        return await Util.getList(returnAsBytes);
    }
    public static async createInvestors(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createInvestor(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createInvestor(ctx: Context, jsonString: string): Promise<any> {
        console.info('😍 😍 🙄 🙄 ### InvestorHelper: createInvestor\n');
        try {
            const jsonObj: any = JSON.parse(jsonString);

            if (!jsonObj.email) {
                return Util.sendError('missing email address');
            }
            if (!jsonObj.name) {
                return Util.sendError('missing name');
            }
            if (!jsonObj.country) {
                return Util.sendError('missing country code');
            }
            const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
                this.DOC_TYPE, [jsonObj.country, jsonObj.email]);
            const res = Util.getList(returnAsBytes);
            if (res.list.length > 0) {
                return Util.sendError(`Investor ${jsonObj.name} already exists`);
            }
            jsonObj.participantId = uuid();
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.dateRegistered = new Date().toISOString();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.country, jsonObj.email]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚 ### InvestorHelper: createInvestor: ${jsonObj.name} added to ledger 💚💚💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create Investor failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

    public static async createTestInvestors(ctx: Context) {
        console.info('😍 😍 ### createTestInvestors ..............\n');
        const investors: Investor[] = [];
        const c1 = {
            cellphone: '088 635 3556',
            country: 'ZA',
            email: 'info@smexinvest.com',
            name: 'SMEX-A Investors Ltd',
        };
        const res1: Investor = await this.createInvestor(ctx, JSON.stringify(c1));
        investors.push(res1);
        const c2 = {
            cellphone: '088 445 3956',
            country: 'ZA',
            email: 'info@gautengfin.com',
            name: 'Gauteng Financiers Ltd',
        };
        const res2: Investor = await this.createInvestor(ctx, JSON.stringify(c2));
        investors.push(res2);

        console.info(`🔵 ### InvestorHelper: createTestInvestors complete. customers added: ${investors.length}`);
        return investors;
    }
}
