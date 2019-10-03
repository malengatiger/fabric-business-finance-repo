import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('DeliveryNote')
export class DeliveryNote {
  @JsonProperty('deliveryNoteId', String)
  public deliveryNoteId: string;
  @JsonProperty('docType', String)
  public docType?: string;
  @JsonProperty('customer', String)
  public customer: string = undefined;
  @JsonProperty('user', String)
  public user: string;
  @JsonProperty('supplier', String)
  public supplier: string = undefined;
  @JsonProperty('supplierName', String)
  public supplierName: string = undefined;
  @JsonProperty('date', String)
  public date: string;

  @JsonProperty('amount', Number)
  public amount: number = undefined;

  @JsonProperty('vat', Number)
  public vat: number = undefined;

  @JsonProperty('totalAmount', Number)
  public totalAmount: number = undefined;

  @JsonProperty('supplierDocumentRef', String)
  public supplierDocumentRef: string;
  @JsonProperty('purchaseOrderNumber', String)
  public purchaseOrderNumber: string;
  @JsonProperty('customerName', String)
  public customerName: string = undefined;
  @JsonProperty('purchaseOrder', String)
  public purchaseOrder: string = undefined;

  @JsonProperty('intDate', Number)
  public intDate: number;
}
