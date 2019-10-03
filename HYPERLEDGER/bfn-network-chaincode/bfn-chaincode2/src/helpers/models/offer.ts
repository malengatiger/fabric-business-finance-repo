import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Offer')
export class Offer {
    public static DOC_TYPE = 'com.oneconnect.biz.Offer';
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('offerId', String)
  public offerId: string;

  @JsonProperty('intDate', Number)
  public intDate: number;

  @JsonProperty('startTime', String)
  public startTime: string = undefined;

  @JsonProperty('endTime', String)
  public endTime: string = undefined;

  @JsonProperty('offerCancellation', String)
  public offerCancellation: string;

  @JsonProperty('invoice', String)
  public invoice: string = undefined;

  @JsonProperty('documentReference', String)
  public documentReference: string;

  @JsonProperty('purchaseOrder', String)
  public purchaseOrder: string;

  @JsonProperty('participantId', String)
  public participantId: string;

  @JsonProperty('wallet', String)
  public wallet: string;

  @JsonProperty('user', String)
  public user: string;

  @JsonProperty('date', String)
  public date: string;

  @JsonProperty('supplier', String)
  public supplier: string = undefined;

  @JsonProperty('contractURL', String)
  public contractURL: string;

  @JsonProperty('invoiceDocumentRef', String)
  public invoiceDocumentRef: string;

  @JsonProperty('supplierName', String)
  public supplierName: string = undefined;

  @JsonProperty('customerName', String)
  public customerName: string = undefined;

  @JsonProperty('customer', String)
  public customer: string = undefined;

  @JsonProperty('dateClosed', String)
  public dateClosed: string;

  @JsonProperty('supplierDocumentRef', String)
  public supplierDocumentRef: string;

  @JsonProperty('invoiceAmount', Number)
  public invoiceAmount: number = undefined;

  @JsonProperty('offerAmount', Number)
  public offerAmount: number = undefined;

  @JsonProperty('discountPercent', Number)
  public discountPercent: number = undefined;

  @JsonProperty('isCancelled', Boolean)
  public isCancelled: boolean = undefined;

  @JsonProperty('isOpen', Boolean)
  public isOpen: boolean = undefined;

  @JsonProperty('sector', String)
  public sector: string;

  @JsonProperty('sectorName', String)
  public sectorName: string;

}
