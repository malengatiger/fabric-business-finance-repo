
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('InvestorProfile')
export class InvestorProfile {
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('profileId', String)
  public profileId: string;

  @JsonProperty('name', String)
  public name: string = undefined;
  @JsonProperty('cellphone', String)
  public cellphone: string = undefined;
  @JsonProperty('email', String)
  public email: string = undefined;
  @JsonProperty('date', String)
  public date: string;

  @JsonProperty('maxInvestableAmount', Number)
  public maxInvestableAmount: number = undefined;

  @JsonProperty('maxInvoiceAmount', Number)
  public maxInvoiceAmount: number = undefined;

  @JsonProperty('minimumDiscount', Number)
  public minimumDiscount: number = undefined;

  @JsonProperty('investor', String)
  public investor: string = undefined;
  @JsonProperty('investorDocRef', String)
  public investorDocRef: string;
  @JsonProperty('sectors', Array)
  public sectors: string[];
  @JsonProperty('suppliers', Array)
  public suppliers: string[];

  @JsonProperty('totalBidAmount', Number)
  public totalBidAmount: number = undefined;
}
