import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Customer } from './models/customer';
import { Util } from './util';

export class CustomerHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.Customer';

    public static async getAllCustomers(ctx: Context): Promise<any> {
        console.info('💋 💋 CustomerHelper: getAllCustomers .........\n\n');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async getCountryCustomers(ctx: Context, countryCode: string): Promise<any> {
        console.info('💋 💋 💋 💋 CustomerHelper: getCountryCustomers .........\n\n');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, [countryCode]);
        return await Util.getList(returnAsBytes);
    }
    public static async createCustomers(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createCustomer(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createCustomer(ctx: Context, jsonString: string): Promise<any> {
        console.info('💋 💋 🙄 🙄 ### CustomerHelper: createCustomer\n');

        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.email) {
                return Util.sendError(`missing email address.`);
            }
            if (!jsonObj.name) {
                return Util.sendError(`missing name.`);
            }
            if (!jsonObj.country) {
                return Util.sendError('missing country code.');
            }
            const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
                this.DOC_TYPE, [jsonObj.country, jsonObj.email]);
            const res = Util.getList(returnAsBytes);
            if (res.list.length > 0) {
                return Util.sendError(`Customer ${jsonObj.name} already exists`);
            }
            jsonObj.participantId = uuid();
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.dateRegistered = new Date().toISOString();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.country, jsonObj.email]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚 ### CustomerHelper: createCustomer: ${jsonObj.name} added to ledger 💚💚💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create Customer failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }
    public static async createTestCustomers(ctx: Context) {
        console.info('💋💋💋💋💋💋 ### createTestCustomers 💋💋💋💋💋💋');
        const customers: Customer[] = [];
        const c1 = {
            cellphone: '088 635 3556',
            country: 'ZA',
            email: 'info@constructors.com',
            name: 'BigD Construction Ltd',
        };
        const res1: Customer = await this.createCustomer(ctx, JSON.stringify(c1));
        customers.push(res1);
        const c2 = {
            cellphone: '088 635 3556',
            country: 'ZA',
            email: 'info@supercon.com',
            name: 'Regional Supermarkets Ltd',
        };
        const res2: Customer = await this.createCustomer(ctx, JSON.stringify(c2));
        customers.push(res2);

        console.info(`\n\n🔵 ### CustomerHelper: createTestCustomers complete. customers added: ${customers.length}`);
        return customers;
    }
}
