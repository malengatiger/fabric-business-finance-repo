import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';

export class PurchaseOrderHelper {
    public static DOC_TYPE = 'com.oneconnect.biz.PurchaseOrder';

    public static async getAllPurchaseOrders(ctx: Context): Promise<any> {
        console.info('💥 💥   PurchaseOrderHelper getAllPurchaseOrders');
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
            this.DOC_TYPE,
            [],
        );
        return await Util.getList(returnAsBytes);
    }
    public static async getCountryPurchaseOrders(
        ctx: Context,
        countryCode: string,
    ): Promise<any> {
        console.info(
            '💥 💥  PurchaseOrderHelper: getCountryPurchaseOrders .........',
        );
        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
            this.DOC_TYPE,
            [countryCode],
        );
        return await Util.getList(returnAsBytes);
    }
    public static async createPurchaseOrders(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createPurchaseOrder(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createPurchaseOrder(
        ctx: Context,
        jsonString: string,
    ): Promise<any> {
        console.info(
            '💥 💥 💥  🙄 🙄 ### PurchaseOrderHelper: createPurchaseOrder',
        );
        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.customer) {
                return Util.sendError('missing customer');
            }
            if (!jsonObj.supplier) {
                return Util.sendError('missing supplier');
            }
            if (!jsonObj.amount) {
                return Util.sendError('missing amount');
            }
            if (!jsonObj.purchaseOrderNumber) {
                return Util.sendError('missing purchaseOrderNumber');
            }
            // todo check for possible duplicate ---
            try {
                const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
                    this.DOC_TYPE,
                    [jsonObj.customer, jsonObj.supplier],
                );
                const res = Util.getList(returnAsBytes);
                res.list.forEach((po) => {
                    if (
                        po.purchaseOrderNumber === jsonObj.purchaseOrderNumber
                    ) {
                        return Util.sendError(
                            `Purchase Order ${
                            jsonObj.purchaseOrderNumber
                            } already exists`,
                        );
                    }
                });
            } catch (e) {
                console.error(`Error looking for existing PO: ${e}`);
            }

            jsonObj.purchaseOrderId = uuid();
            jsonObj.docType = this.DOC_TYPE;
            jsonObj.date = new Date().toISOString();
            jsonObj.intDate = new Date().getTime();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE, [
                jsonObj.customer,
                jsonObj.supplier,
                jsonObj.date,
            ]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            console.info(
                `💚 💚 💚  ### PurchaseOrderHelper: createPO: ${
                jsonObj.customer
                } added to ledger 💚💚💚`,
            );
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(
                `Create PurchaseOrder failed, jsonString: ${jsonString} ERROR: ${e}`,
            );
        }
    }
}
