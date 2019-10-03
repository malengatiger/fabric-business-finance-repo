import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('InvoiceBid')
export class InvoiceBid {
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('invoiceBidId', String)
  public invoiceBidId: string | undefined;
  @JsonProperty('startTime', String)
  public startTime: string | undefined;
  @JsonProperty('endTime', String)
  public endTime: string | undefined;

  @JsonProperty('reservePercent', Number)
  public reservePercent: number | undefined;

  @JsonProperty('amount', Number)
  public amount: number | undefined;

  @JsonProperty('discountPercent', Number)
  public discountPercent: number | undefined;

  @JsonProperty('offer', String)
  public offer: string | undefined;
  @JsonProperty('supplierFCMToken', String)
  public supplierFCMToken: string | undefined;
  @JsonProperty('wallet', String)
  public wallet: string | undefined;
  @JsonProperty('investor', String)
  public investor: string | undefined;
  @JsonProperty('date', String)
  public date: string | undefined;
  @JsonProperty('autoTradeOrder', String)
  public autoTradeOrder: string | undefined;
  @JsonProperty('user', String)
  public user: string | undefined;
  @JsonProperty('documentReference', String)
  public documentReference: string | undefined;
  @JsonProperty('supplier', String)
  public supplier: string | undefined;
  @JsonProperty('invoiceBidAcceptance', String)
  public invoiceBidAcceptance: string | undefined;
  @JsonProperty('investorName', String)
  public investorName: string | undefined;

  @JsonProperty('isSettled', Boolean)
  public isSettled: boolean | undefined;

  @JsonProperty('supplierName', String)
  public supplierName: string | undefined;
  @JsonProperty('customerName', String)
  public customerName: string | undefined;
  @JsonProperty('customer', String)
  public customer: string | undefined;
  @JsonProperty('supplierDocRef', String)
  public supplierDocRef: string | undefined;
  @JsonProperty('offerDocRef', String)
  public offerDocRef: string | undefined;
  @JsonProperty('investorDocRef', String)
  public investorDocRef: string | undefined;

  @JsonProperty('intDate', Number)
  public intDate: number | undefined;
}
