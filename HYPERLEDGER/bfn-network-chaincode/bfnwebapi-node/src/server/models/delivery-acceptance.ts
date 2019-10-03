
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('DeliveryAcceptance')
export class DeliveryAcceptance {
  @JsonProperty('acceptanceId', String)
  public acceptanceId: string | undefined;

  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('customer', String)
  public customer: string | undefined;
  @JsonProperty('customerName', String)
  public customerName: string | undefined;

  @JsonProperty('deliveryNote', String)
  public deliveryNote: string | undefined;

  @JsonProperty('supplier', String)
  public supplier: string | undefined;
  @JsonProperty('supplierName', String)
  public supplierName: string | undefined;

  @JsonProperty('purchaseOrder', String)
  public purchaseOrder: string | undefined;

  @JsonProperty('date', String)
  public date: string | undefined;
}
