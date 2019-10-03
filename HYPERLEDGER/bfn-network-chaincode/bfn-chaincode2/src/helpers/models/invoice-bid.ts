import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('InvoiceBid')
export class InvoiceBid {
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('invoiceBidId', String)
  public invoiceBidId: string;
  @JsonProperty('startTime', String)
  public startTime: string = undefined;
  @JsonProperty('endTime', String)
  public endTime: string = undefined;

  @JsonProperty('reservePercent', Number)
  public reservePercent: number = undefined;

  @JsonProperty('amount', Number)
  public amount: number = undefined;

  @JsonProperty('discountPercent', Number)
  public discountPercent: number = undefined;

  @JsonProperty('offer', String)
  public offer: string = undefined;
  @JsonProperty('supplierFCMToken', String)
  public supplierFCMToken: string;
  @JsonProperty('wallet', String)
  public wallet: string;
  @JsonProperty('investor', String)
  public investor: string = undefined;
  @JsonProperty('date', String)
  public date: string;
  @JsonProperty('autoTradeOrder', String)
  public autoTradeOrder: string;
  @JsonProperty('user', String)
  public user: string;
  @JsonProperty('documentReference', String)
  public documentReference: string;
  @JsonProperty('supplier', String)
  public supplier: string = undefined;
  @JsonProperty('invoiceBidAcceptance', String)
  public invoiceBidAcceptance: string;
  @JsonProperty('investorName', String)
  public investorName: string = undefined;

  @JsonProperty('isSettled', Boolean)
  public isSettled: boolean = undefined;

  @JsonProperty('supplierName', String)
  public supplierName: string = undefined;
  @JsonProperty('customerName', String)
  public customerName: string = undefined;
  @JsonProperty('customer', String)
  public customer: string = undefined;
  @JsonProperty('supplierDocRef', String)
  public supplierDocRef: string;
  @JsonProperty('offerDocRef', String)
  public offerDocRef: string;
  @JsonProperty('investorDocRef', String)
  public investorDocRef: string;

  @JsonProperty('intDate', Number)
  public intDate: number;
}
