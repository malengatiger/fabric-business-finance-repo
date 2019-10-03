import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class UserHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.User';

    public static async getAllUsers(ctx: Context): Promise<any> {
        console.info('💋 💋 UserHelper: getAllCustomers .........\n\n');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async createUsers(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createUser(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createUser(ctx: Context, jsonString: string): Promise<any> {
        console.info('💋 💋 🙄 🙄 ### UserHelper: createUser\n');

        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.email) {
                return Util.sendError('missing email address');
            }
            if (!jsonObj.firstName) {
                return Util.sendError('missing firstName');
            }
            if (!jsonObj.lastName) {
                return Util.sendError('missing lastName');
            }
            if (!jsonObj.investor && !jsonObj.supplier && !jsonObj.customer) {
                return Util.sendError('user has missing entity; investor or customer or supplier');
            }
            const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
                this.DOC_TYPE, [jsonObj.email]);
            const res = Util.getList(returnAsBytes);
            if (res.list.length > 0) {
                return Util.sendError(`User ${jsonObj.email} already exists`);
            }
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.userId = uuid();
            jsonObj.dateRegistered = new Date().toISOString();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.email]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚  ### UserHelper: createUser: ${jsonObj.name} added to ledger 💚💚💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create User failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

}
