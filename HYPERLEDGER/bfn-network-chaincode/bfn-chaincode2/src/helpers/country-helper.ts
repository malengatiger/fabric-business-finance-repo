import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class CountryHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.Country';

    public static async getAllCountries(ctx: Context): Promise<any> {
        console.info('💋 💋 CountryHelper: getAllCountries .........\n\n');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async createCountries(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createCountry(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createCountry(ctx: Context, jsonString: string): Promise<any> {
        console.info('💋 💋 🙄 🙄 ### CountryHelper: createCountry\n');

        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.name) {
                return Util.sendError('missing Country name');
            }
            if (!jsonObj.code) {
                return Util.sendError('missing Code ');
            }
            const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
                this.DOC_TYPE, [jsonObj.code, jsonObj.name]);
            const res = Util.getList(returnAsBytes);
            if (res.list.length > 0) {
                return Util.sendError(`Country ${jsonObj.name} already exists`);
            }
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.countryId = uuid();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.code, jsonObj.name]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚 ### CountryHelper: createCountry: ${jsonObj.name} added to ledger 💚 💚 💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create Country failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

}
