
import { Context, Contract } from 'fabric-contract-api';
import { AutoTradeStartHelper } from './helpers/autotrade-start-helper';
import { AutoTradeOrderHelper } from './helpers/autotradeorder-helper';
import { CountryHelper } from './helpers/country-helper';
import { CustomerHelper } from './helpers/customer-helper';
import { DeliveryNoteHelper } from './helpers/delivery-note-helper';
import { InvestorHelper } from './helpers/investor-helper';
import { InvestorProfileHelper } from './helpers/investorprofile-helper';
import { InvoiceHelper } from './helpers/invoice-helper';
import { InvoiceBidHelper } from './helpers/invoicebid-helper';
import { OfferHelper } from './helpers/offer-helper';
import { PurchaseOrderHelper } from './helpers/purchase-order-helper';
import { SectorHelper } from './helpers/sector-helper';
import { StellarHelper } from './helpers/stellar-helper';
import { SupplierHelper } from './helpers/supplier-helper';
import { UserHelper } from './helpers/user-helper';
import { Util } from './helpers/util';

export class BFNContractOne extends Contract {
    constructor() {
        super('BFNContractOne');
    }
    public async addPurchaseOrder(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addPurchaseOrder');
        const result = await PurchaseOrderHelper.createPurchaseOrder(
            ctx,
            jsonString,
        );
        return result;
    }
    public async addPurchaseOrders(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addPurchaseOrder');
        const result = await PurchaseOrderHelper.createPurchaseOrders(
            ctx,
            jsonString,
        );
        return result;
    }
    public async addDeliveryNote(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addDeliveryNote');
        const result = await DeliveryNoteHelper.createDeliveryNote(
            ctx,
            jsonString,
        );
        return result;
    }
    public async addDeliveryNotes(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addDeliveryNotes');
        const result = await DeliveryNoteHelper.createDeliveryNotes(
            ctx,
            jsonString,
        );
        return result;
    }
    public async acceptDeliveryNote(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: acceptDeliveryNote:');

        const result = await DeliveryNoteHelper.acceptDelivery(ctx, jsonString);
        return result;
    }
    public async acceptDeliveryNotes(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: acceptDeliveryNotes:');
        const result = await DeliveryNoteHelper.acceptDeliveries(ctx, jsonString);
        return result;
    }
    public async addInvoice(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addInvoice');
        const result = await InvoiceHelper.createInvoice(ctx, jsonString);
        return result;
    }
    public async addInvoices(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addInvoices');
        const result = await InvoiceHelper.createInvoices(ctx, jsonString);
        return result;
    }
    public async addStellarWallets(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addStelarWallets');
        const result = await StellarHelper.createWallets(ctx, jsonString);
        return result;
    }
    public async addStellarWallet(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addStellarWallet');
        const result = await StellarHelper.createWallet(ctx, jsonString);
        return result;
    }
    public async acceptInvoice(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: acceptInvoice');
        const result = await InvoiceHelper.acceptInvoice(ctx, jsonString);
        return result;
    }
    public async acceptInvoices(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: acceptInvoice');
        const result = await InvoiceHelper.acceptInvoices(ctx, jsonString);
        return result;
    }
    public async addOffer(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addOffer');
        const result = await OfferHelper.createOffer(ctx, jsonString);
        return result;
    }
    public async addOffers(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addOffers');
        const result = await OfferHelper.createOffers(ctx, jsonString);
        return result;
    }
    public async cancelOffer(ctx: Context, jsonString: string): Promise<any> {
        const result = await OfferHelper.cancelOffer(ctx, jsonString);
        return result;
    }
    public async closeOffer(ctx: Context, jsonString: string): Promise<any> {
        const result = await OfferHelper.closeOffer(ctx, jsonString);
        return result;
    }
    public async addInvoiceBid(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addInvoiceBid');
        const result = await InvoiceBidHelper.createInvoiceBid(ctx, jsonString);
        return result;
    }
    public async addCustomer(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addCustomer:');
        const result = await CustomerHelper.createCustomer(ctx, jsonString);
        return result;
    }
    public async addCustomers(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addCustomers:');
        const result = await CustomerHelper.createCustomers(ctx, jsonString);
        return result;
    }
    public async addUser(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addUser:');
        const result = await UserHelper.createUser(ctx, jsonString);
        return result;
    }
    public async addUsers(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addUsers:');
        const result = await UserHelper.createUsers(ctx, jsonString);
        return result;
    }
    public async addSector(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addSector:');
        const result = await SectorHelper.createSector(ctx, jsonString);
        return result;
    }
    public async addSectors(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addSectors:');
        const result = await SectorHelper.createSectors(ctx, jsonString);
        return result;
    }
    public async addInvestorProfile(ctx: Context, jsonString: string ): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addInvestorProfile:');
        const result = await InvestorProfileHelper.createInvestorProfile(
            ctx,
            jsonString,
        );

        return result;
    }
    public async addInvestorProfiles(ctx: Context, jsonString: string ): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addInvestorProfiles:');
        const result = await InvestorProfileHelper.createInvestorProfiles(
            ctx,
            jsonString,
        );

        return result;
    }
    public async addAutoTradeOrder(ctx: Context, jsonString: string ): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addAutoTradeOrder:');
        const result = await AutoTradeOrderHelper.createAutoTradeOrder(
            ctx,
            jsonString,
        );
        return result;
    }
    public async addAutoTradeOrders(ctx: Context, jsonString: string ): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addAutoTradeOrders:');
        const result = await AutoTradeOrderHelper.createAutoTradeOrders(
            ctx,
            jsonString,
        );
        return result;
    }
    public async addAutoTradeStart(ctx: Context, jsonString: string ): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addAutoTradeStart:');
        const result = await AutoTradeStartHelper.createAutoTradeStart(
            ctx,
            jsonString,
        );
        return result;
    }
    public async addCountry(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addCountry:');
        const result = await CountryHelper.createCountry(ctx, jsonString);
        return result;
    }
    public async addCountries(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addCountry:');
        const result = await CountryHelper.createCountries(ctx, jsonString);
        return result;
    }
    public async addSupplier(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addSupplier:');
        const result = await SupplierHelper.createSupplier(ctx, jsonString);
        return result;
    }
    public async addSuppliers(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addSuppliers:');
        const result = await SupplierHelper.createSuppliers(ctx, jsonString);
        return result;
    }
    public async addInvestor(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addInvestor:');
        const result = await InvestorHelper.createInvestor(ctx, jsonString);
        return result;
    }
    public async addInvestors(ctx: Context, jsonString: string): Promise<any> {
        console.info('🔵 🔵 ### BFNContractOne: addInvestors:');
        const result = await InvestorHelper.createInvestors(ctx, jsonString);
        return result;
    }
    public async getAllCustomers(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllCustomers ...');
        const result = await CustomerHelper.getAllCustomers(ctx);
        return result;
    }
    public async getAllSectors(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllSectors ...');
        const result = await SectorHelper.getAllSectors(ctx);
        return result;
    }
    public async getAllCountries(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllCountries ...');
        const result = await CountryHelper.getAllCountries(ctx);
        return result;
    }
    public async getAllPurchaseOrders(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllPurchaseOrder ...');
        const result = await PurchaseOrderHelper.getAllPurchaseOrders(ctx);
        return result;
    }
    public async getAllDeliveryNotes(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllDeliveryNotes ...');
        const result = await DeliveryNoteHelper.getAllDeliveryNotes(ctx);
        return result;
    }
    public async getAllDeliveryAcceptances(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllDeliveryAcceptances ...');
        const result = await DeliveryNoteHelper.getAllDeliveryAcceptances(ctx);
        return result;
    }
    public async getAllInvoices(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllInvoices ...');
        const result = await InvoiceHelper.getAllInvoices(ctx);
        return result;
    }
    public async getAllInvoiceAcceptances(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllInvoiceAcceptances ...');
        const result = await InvoiceHelper.getAllInvoiceAcceptances(ctx);
        return result;
    }
    public async getAllOffers(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllOffers ...');
        const result = await OfferHelper.getAllOffers(ctx);
        return result;
    }
    public async getAllInvoiceBids(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllInvoiceBids ...');
        const result = await InvoiceBidHelper.getAllInvoiceBids(ctx);
        return result;
    }
    public async getCountryCustomers(ctx: Context, countryCode: string): Promise<any> {
        console.info('🔵 ### BFNContractOne: getCountryCustomers ...');
        const result = await CustomerHelper.getCountryCustomers(
            ctx,
            countryCode,
        );
        return result;
    }
    public async getAllSuppliers(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllSuppliers ...');
        const result = await SupplierHelper.getAllSuppliers(ctx);
        return result;
    }
    public async getCountrySuppliers(ctx: Context, countryCode: string): Promise<any> {
        console.info('🔵 ### BFNContractOne: getCountrySuppliers ...');
        const result = await SupplierHelper.getCountrySuppliers(
            ctx,
            countryCode,
        );
        return result;
    }
    public async getAllInvestors(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllInvestors ...');
        const result = await InvestorHelper.getAllInvestors(ctx);
        return result;
    }
    public async getAllWallets(ctx: Context): Promise<any> {
        console.info('🔵 ### BFNContractOne: getAllWallets ...');
        const result = await StellarHelper.getAllWallets(ctx);
        return result;
    }
    public async getCountryInvestors(ctx: Context, countryCode: string): Promise<any> {
        console.info('🔵 ### BFNContractOne: getCountryInvestors ...');
        const result = await InvestorHelper.getCountryInvestors(
            ctx,
            countryCode,
        );
        return result;
    }
    public async unknownTransaction(ctx: Context) {
        console.error('😡 😡 😡 Unknown transaction encountered 😡 😡 😡');
        Util.sendError('BFN does not recognize you, so fuck off!');
    }
    // public async beforeTransaction(ctx: Context) {
    //     console.info(
    //         `👉 👉 👉 beforeTransaction: Transaction ID: ${ctx.stub.getTxID()}`,
    //     );
    // }
    // public async afterTransaction(ctx: Context, result) {
    //     console.log(`💦 💦 💦 afterTransaction, status: ${result}`);
    //     return result;
    // }
    public async init(ctx: Context) {
        console.log(
            '\n\n🔵 🔵 🔵 🔵 🔵 🔵  BFNContractOne has been initialized ' +
            ctx.clientIdentity.getID(),
        );
        return {
            message:
                '🔵 🔵 🔵 🔵 🔵 🔵 BFNContractOne has been initialized 🔵 🔵 🔵 🔵 🔵 🔵 ' +
                ctx.clientIdentity.getID() +
                ' on: ' +
                new Date().toISOString(),
            statusCode: 200,
        };
    }
    public async addFakes(ctx: Context): Promise<any> {
        console.info(
            '🔵 🔵 ### BFNContractOne: addFakes just customers for now ...',
        );

        try {
            const result = await CustomerHelper.createTestCustomers(ctx);
            const result2 = await SupplierHelper.createTestSuppliers(ctx);
            const result3 = await InvestorHelper.createTestInvestors(ctx);

            const finalResult = {
                customers: result,
                investors: result3,
                suppliers: result2,
            };

            console.info(`✅  ✅  BFNContractOne: addFakes. COMPLETE`);
            return finalResult;
        } catch (e) {
            throw new Error(`😡 😡 😡 addFakes Test data failed`);
        }
    }
}
