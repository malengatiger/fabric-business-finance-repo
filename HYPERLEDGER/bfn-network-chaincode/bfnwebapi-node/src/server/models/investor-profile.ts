
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('InvestorProfile')
export class InvestorProfile {
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('profileId', String)
  public profileId: string | undefined;

  @JsonProperty('name', String)
  public name: string | undefined;
  @JsonProperty('cellphone', String)
  public cellphone: string | undefined;
  @JsonProperty('email', String)
  public email: string | undefined;
  @JsonProperty('date', String)
  public date: string | undefined;

  @JsonProperty('maxInvestableAmount', Number)
  public maxInvestableAmount: number = 0.0;

  @JsonProperty('maxInvoiceAmount', Number)
  public maxInvoiceAmount: number = 0.0;

  @JsonProperty('minimumDiscount', Number)
  public minimumDiscount: number = 0.0;

  @JsonProperty('investor', String)
  public investor: string | undefined;
  @JsonProperty('investorDocRef', String)
  public investorDocRef: string | undefined;
  @JsonProperty('sectors', Array)
  public sectors: string[] = [];
  @JsonProperty('suppliers', Array)
  public suppliers: string[] = [];

  @JsonProperty('totalBidAmount', Number)
  public totalBidAmount: number = 0.0;
}
