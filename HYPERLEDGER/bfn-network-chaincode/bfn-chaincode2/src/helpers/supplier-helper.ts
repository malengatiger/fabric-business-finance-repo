import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Supplier } from './models/supplier';
import { Util } from './util';

export class SupplierHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.Supplier';

    public static async getAllSuppliers(ctx: Context): Promise<any> {
        console.info('💜 💜  SupplierHelper getAllSuppliers 💜 💜 ');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, []);
        const suppliers = await Util.getList(returnAsBytes);
        return suppliers;
    }
    public static async getCountrySuppliers(ctx: Context, countryCode: string): Promise<any> {
        console.info('CustomerHelper: getCountrySuppliers .........');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE, [countryCode]);
        const suppliers = await Util.getList(returnAsBytes);
        return suppliers;
    }
    public static async createSuppliers(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createSupplier(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createSupplier(ctx: Context, jsonString: string): Promise<any> {
        console.info(`🙄 🙄 💜 💜 ### SupplierHelper: createSupplier: ${jsonString}`);
        try {
            const jsonObj = JSON.parse(jsonString);

            if (!jsonObj.name) {
                return Util.sendError('missing name');
            }
            if (!jsonObj.email) {
                return Util.sendError('missing email address');
            }
            if (!jsonObj.country) {
                return Util.sendError('missing country code');
            }
            const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
                this.DOC_TYPE, [jsonObj.country, jsonObj.email]);
            const res = Util.getList(returnAsBytes);
            if (res.list.length > 0) {
                return Util.sendError(`Supplier ${jsonObj.name} already exists`);
            }
            jsonObj.participantId = uuid();
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.dateRegistered = new Date().toISOString();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [jsonObj.country, jsonObj.email]);
            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(`💚 💚 💚 ### SupplierHelper: createSupplier: ${jsonObj.name} added to ledger 💚💚💚`);

            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create Supplier failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

    public static async createTestSuppliers(ctx: Context) {
        console.info('ℹ️ ### createTestSuppliers ..............');
        const suppliers: Supplier[] = [];
        const c1 = {
            cellphone: '088 909 6576',
            country: 'ZA',
            email: 'info@matsupp.com',
            name: 'Material Supply Ltd',
        };
        const res1: Supplier = await this.createSupplier(ctx, JSON.stringify(c1));
        suppliers.push(res1);
        const c2 = {
            cellphone: '088 555 5744',
            country: 'ZA',
            email: 'info@drakenscom.com',
            name: 'Drakensberg Supply Company',
        };
        const res2: Supplier = await this.createSupplier(ctx, JSON.stringify(c2));
        suppliers.push(res2);

        console.info(`🔵 ### SupplierHelper: createTestSuppliers complete. customers added: ${suppliers.length}`);
        return suppliers;
    }
}
