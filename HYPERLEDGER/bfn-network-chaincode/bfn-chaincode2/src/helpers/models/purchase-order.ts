import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('PurchaseOrder')
export class PurchaseOrder {
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('purchaseOrderId', String)
  public purchaseOrderId: string;
  @JsonProperty('supplier', String)
  public supplier: string = undefined;
  @JsonProperty('customer', String)
  public customer: string = undefined;
  @JsonProperty('date', String)
  public date: string;
  @JsonProperty('intDate', Number)
  public intDate: number;
  @JsonProperty('amount', Number)
  public amount: number = undefined;
  @JsonProperty('purchaseOrderNumber', String)
  public purchaseOrderNumber: string = undefined;
  @JsonProperty('customerName', String)
  public customerName: string = undefined;
  @JsonProperty('supplierName', String)
  public supplierName: string = undefined;
  @JsonProperty('supplierDocumentRef', String)
  public supplierDocumentRef: string;
  @JsonProperty('customerDocumentRef', String)
  public customerDocumentRef: string;
  @JsonProperty('documentReference', String)
  public documentReference: string;
}
