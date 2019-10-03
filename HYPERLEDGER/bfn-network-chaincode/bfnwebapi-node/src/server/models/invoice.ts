import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Invoice')
export class Invoice {
  @JsonProperty('invoiceId', String)
  public invoiceId: string | undefined;
  @JsonProperty('docType', String)
  public docType: string | undefined;

  @JsonProperty('purchaseOrder', String)
  public purchaseOrder: string | undefined;
  @JsonProperty('invoiceNumber', String)
  public invoiceNumber: string | undefined;
  @JsonProperty('date', String)
  public date: string | undefined;
  @JsonProperty('intDate', Number)
  public intDate: number | undefined;
  @JsonProperty('amount', Number)
  public amount: number | undefined;
  @JsonProperty('purchaseOrderNumber', String)
  public purchaseOrderNumber: string | undefined;
  @JsonProperty('customerName', String)
  public customerName: string | undefined;
  @JsonProperty('supplierName', String)
  public supplierName: string | undefined;
  @JsonProperty('customer', String)
  public customer: string | undefined;
  @JsonProperty('totalAmount', Number)
  public totalAmount: number | undefined;
  @JsonProperty('valueAddedTax', Number)
  public valueAddedTax: number | undefined;
  @JsonProperty('supplier', String)
  public supplier: string | undefined;
  @JsonProperty('isOnOffer', Boolean)
  public isOnOffer: boolean | undefined;
  @JsonProperty('isSettled', Boolean)
  public isSettled: boolean | undefined;
  @JsonProperty('contractURL', String)
  public contractURL: string | undefined;
  @JsonProperty('deliveryNote', String)
  public deliveryNote: string | undefined;
}
