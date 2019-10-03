import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('InvalidSummary')
export class InvalidSummary {
    @JsonProperty()
    public isValidInvoiceAmount: number = 0;
    @JsonProperty()
    public isValidBalance: number = 0;
    @JsonProperty()
    public isValidSector: number = 0;
    @JsonProperty()
    public isValidSupplier: number = 0;
    @JsonProperty()
    public isValidMinimumDiscount: number = 0;
    @JsonProperty()
    public isValidInvestorMax: number = 0;
    @JsonProperty()
    public invalidTrades: number = 0;
    @JsonProperty()
    public totalOpenOffers: number = 0;
    @JsonProperty()
    public totalUnits: number = 0;
    @JsonProperty()
    public date: string = new Date().toISOString();

    public toJSON() {
        return {
            isValidBalance: this.isValidBalance,
            isValidInvoiceAmount: this.isValidInvoiceAmount,
            isValidSector: this.isValidSector,
            isValidSupplier: this.isValidSupplier,
            // tslint:disable-next-line:object-literal-sort-keys
            isValidMinimumDiscount: this.isValidMinimumDiscount,
            isValidInvestorMax: this.isValidInvestorMax,
            invalidTrades: this.invalidTrades,
            totalOpenOffers: this.totalOpenOffers,
            totalUnits: this.totalUnits,
            date: this.date,
        };
    }
}
