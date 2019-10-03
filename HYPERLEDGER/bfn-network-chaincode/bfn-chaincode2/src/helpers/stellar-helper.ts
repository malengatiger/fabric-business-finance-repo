import { Context } from 'fabric-contract-api';
import { Util } from './util';

export class StellarHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.Wallet';

    public static async getAllWallets(ctx: Context): Promise<any> {
        console.info('💋 💋 StellarHelper: getAllWallets .........\n\n');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async createWallets(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createWallet(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createWallet(ctx: Context, jsonString: string): Promise<any> {
        console.info('💋 💋 🙄 🙄 ### StellarHelper: createWallet\n');

        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.participantId) {
                return Util.sendError(`missing participantId : ${jsonString} `);
            }
            if (!jsonObj.stellarPublicKey) {
                return Util.sendError(`missing stellarPublicKey : ${jsonString} `);
            }
            const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, [jsonObj.participantId]);
            const res = Util.getList(returnAsBytes);
            if (res.list.length > 0) {
                return Util.sendError(`Wallet ${jsonObj.participantId} already exists`);
            }
            jsonObj.docType = this.DOC_TYPE;

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.participantId]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚 ### StellarHelper: createWallet: ${jsonObj.participantId} added to ledger 💚💚💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create Wallet failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

}
