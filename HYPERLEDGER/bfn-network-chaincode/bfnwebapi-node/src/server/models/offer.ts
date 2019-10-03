import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Offer')
export class Offer {
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('offerId', String)
  public offerId: string | undefined;

  @JsonProperty('intDate', Number)
  public intDate: number | undefined;

  @JsonProperty('startTime', String)
  public startTime: string | undefined;

  @JsonProperty('endTime', String)
  public endTime: string | undefined;

  @JsonProperty('offerCancellation', String)
  public offerCancellation: string | undefined;

  @JsonProperty('invoice', String)
  public invoice: string | undefined;

  @JsonProperty('documentReference', String)
  public documentReference: string | undefined;

  @JsonProperty('purchaseOrder', String)
  public purchaseOrder: string | undefined;

  @JsonProperty('participantId', String)
  public participantId: string | undefined;

  @JsonProperty('wallet', String)
  public wallet: string | undefined;

  @JsonProperty('user', String)
  public user: string | undefined;

  @JsonProperty('date', String)
  public date: string | undefined;

  @JsonProperty('supplier', String)
  public supplier: string | undefined;

  @JsonProperty('contractURL', String)
  public contractURL: string | undefined;

  @JsonProperty('invoiceDocumentRef', String)
  public invoiceDocumentRef: string | undefined;

  @JsonProperty('supplierName', String)
  public supplierName: string | undefined;

  @JsonProperty('customerName', String)
  public customerName: string | undefined;

  @JsonProperty('customer', String)
  public customer: string | undefined;

  @JsonProperty('dateClosed', String)
  public dateClosed: string | undefined;

  @JsonProperty('invoiceAmount', Number)
  public invoiceAmount: number = 0.0;

  @JsonProperty('offerAmount', Number)
  public offerAmount: number = 0.0;

  @JsonProperty('discountPercent', Number)
  public discountPercent: number = 0.0;

  @JsonProperty('isCancelled', Boolean)
  public isCancelled: boolean = false;

  @JsonProperty('isOpen', Boolean)
  public isOpen: boolean = true;

  @JsonProperty('sector', String)
  public sector: string | undefined;

  @JsonProperty('sectorName', String)
  public sectorName: string | undefined;

}
