import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class SectorHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.Sector';

    public static async getAllSectors(ctx: Context): Promise<any> {
        console.info('💋 💋 SectorHelper: getAllCustomers .........\n\n');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }

    public static async createSectors(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createSector(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createSector(ctx: Context, jsonString: string): Promise<any> {
        console.info('💋 💋 🙄 🙄 ### SectorHelper: createSector\n');

        try {

            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.sectorName) {
                return Util.sendError(`missing sectorName : ${jsonString} `);
            }
            const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, [jsonObj.sectorName]);
            const res = Util.getList(returnAsBytes);
            if (res.list.length > 0) {
                return Util.sendError(`Sector ${jsonObj.sectorName} already exists`);
            }
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.sectorId = uuid();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.sectorName]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚 ### SectorHelper: createSector: ${jsonObj.sectorName} added to ledger 💚💚💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create Sector failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

}
