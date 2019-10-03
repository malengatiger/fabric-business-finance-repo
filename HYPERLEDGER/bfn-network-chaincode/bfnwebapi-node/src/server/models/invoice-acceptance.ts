
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('InvoiceAcceptance')
export class InvoiceAcceptance {
  @JsonProperty('acceptanceId', String)
  public acceptanceId: string | undefined;

  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('customerName', String)
  public customer: string | undefined;

  @JsonProperty('invoiceNumber', String)
  public invoiceNumber: string | undefined;
  @JsonProperty('supplier', String)
  public supplier: string | undefined;
  @JsonProperty('supplierName', String)
  public supplierName: string | undefined;
  @JsonProperty('invoice', String)
  public invoice: string | undefined;
  @JsonProperty('date', String)
  public date: string | undefined;

}
