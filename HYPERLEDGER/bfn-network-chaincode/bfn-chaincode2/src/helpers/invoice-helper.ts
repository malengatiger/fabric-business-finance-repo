import { Context } from 'fabric-contract-api';
import * as uuid from 'uuid/v1';
import { Util } from './util';
import { Iterators } from 'fabric-shim';

export class InvoiceHelper {
    public static DOC_TYPE_INVOICE = 'com.oneconnect.biz.Invoice';
    public static DOC_TYPE_ACCEPT = 'com.oneconnect.biz.InvoiceAcceptance';

    public static async getAllInvoices(ctx: Context): Promise<any> {
        console.info('😎 😎 😎InvoiceHelper getAllInvoices');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_INVOICE, []);
        return await Util.getList(returnAsBytes);
    }
    public static async getAllInvoiceAcceptances(ctx: Context): Promise<any> {
        console.info('😎 😎 😎InvoiceHelper getAllInvoiceAcceptances');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_ACCEPT, []);
        return await Util.getList(returnAsBytes);
    }
    public static async getInvoicesByCustomer(ctx: Context, customer: string): Promise<any> {
        console.info('😎 😎 😎InvoiceHelper: getInvoicesByCustomer .........');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_INVOICE, [customer]);
        return await Util.getList(returnAsBytes);
    }
    public static async getInvoicesBySupplier(ctx: Context, supplier: string): Promise<any> {
        console.info('😎 😎 😎InvoiceHelper: getInvoicesBySupplier .........');

        const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(this.DOC_TYPE_INVOICE, ['', supplier]);
        return await Util.getList(returnAsBytes);
    }
    public static async createInvoices(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.createInvoice(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async createInvoice(ctx: Context, jsonString: string): Promise<any> {
        console.info('😎 😎 😎### InvoiceHelper: createInvoice 💦 \n');
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
            if (!jsonObj.purchaseOrder) {
                return Util.sendError('missing purchase order');
            }
            if (!jsonObj.invoiceNumber) {
                return Util.sendError('missing invoiceNumber order');
            }
            // todo check that purchase order exists and that there are no other jsonObj notes ---
            // todo check for possible duplicate ---
            try {
                const returnAsBytes = await ctx.stub.getStateByPartialCompositeKey(
                    this.DOC_TYPE_INVOICE, [jsonObj.supplier, jsonObj.customer]);
                const res = Util.getList(returnAsBytes);
                res.list.forEach((invoice) => {
                    if (invoice.invoiceNumber === jsonObj.invoiceNumber) {
                        return Util.sendError(`Invoice ${jsonObj.invoiceNumber} already exists`);
                    }
                });
            } catch (e) {
                const msg = `👿 👿 Error looking for existing invoice: ${e}`;
                return Util.sendError(msg);
            }
            jsonObj.invoiceId = uuid();
            jsonObj.docType = this.DOC_TYPE_INVOICE;
            jsonObj.date = new Date().toISOString();
            jsonObj.intDate = new Date().getTime();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE_INVOICE,
                [jsonObj.invoiceId, jsonObj.supplier, jsonObj.customer, jsonObj.date]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            // tslint:disable-next-line:max-line-length
            console.info(`💚 💚 💚 ### jsonObjHelper: 💦 createInvoice: ${jsonObj.supplierName} added to ledger 💚💚💚`);
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`Create Invoice failed, jsonString: ${jsonString} ERROR: ${e}`);
        }
    }

    public static async acceptInvoices(ctx: Context, jsonString: string): Promise<any> {
        const list: any[] = JSON.parse(jsonString);
        for (const obj of list) {
            const m = await this.acceptInvoice(ctx, JSON.stringify(obj));
            if (m.statusCode === 200) {
                list.push(m.result);
            }
        }
        return {
            result: list,
            statusCode: 200,
        };
    }
    public static async acceptInvoice(ctx: Context, jsonString: string): Promise<any> {
        console.info('😎 😎 😎### InvoiceHelper: acceptInvoice 💦 \n');
        try {
            const jsonObj: any = JSON.parse(jsonString);
            if (!jsonObj.customer) {
                return Util.sendError('missing customer');
            }
            if (!jsonObj.supplier) {
                return Util.sendError('missing supplier');
            }
            if (!jsonObj.invoice) {
                return Util.sendError('missing amount');
            }
            if (!jsonObj.supplierName) {
                return Util.sendError('missing supplier name');
            }

            jsonObj.acceptanceId = uuid();
            jsonObj.docType = this.DOC_TYPE_ACCEPT;
            jsonObj.date = new Date().toISOString();

            const key = ctx.stub.createCompositeKey(this.DOC_TYPE_ACCEPT,
                [jsonObj.customer, jsonObj.supplier, jsonObj.date]);

            await ctx.stub.putState(key, Buffer.from(JSON.stringify(jsonObj)));
            // tslint:disable-next-line:max-line-length
            console.log(`💚💚💚 ### InvoiceHelper: 💦 acceptInvoice: ${jsonObj.supplierName} added to ledger 💚💚💚`);

            try {
                // update invoice with this acceptance
                const bytes: Iterators.StateQueryIterator = await ctx.stub
                    .getStateByPartialCompositeKey(this.DOC_TYPE_INVOICE, [jsonObj.invoiceId]);
                const invoice = Util.getObject(bytes);
                invoice.invoiceAcceptance = jsonObj.acceptanceId;
                const key2 = ctx.stub.createCompositeKey(this.DOC_TYPE_INVOICE,
                    [jsonObj.invoiceId, jsonObj.supplier, jsonObj.customer, jsonObj.date]);

                await ctx.stub.putState(key2, Buffer.from(JSON.stringify(invoice)));
            } catch (err) {
                console.error(`🍏 🍎 acceptInvoice OK; 🌶 invoiceUpdate failed: ${jsonString}: ${err}`);
            }
            return Util.sendResult(jsonObj);
        } catch (e) {
            return Util.sendError(`acceptInvoice failed, 🌶 🌶 🌶 : ${jsonString} ERROR: ${e}`);
        }
    }

}
