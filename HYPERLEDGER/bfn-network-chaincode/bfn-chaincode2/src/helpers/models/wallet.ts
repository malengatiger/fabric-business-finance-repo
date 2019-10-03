import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Wallet')
export class Wallet {
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('dateRegistered', String)
  public dateRegistered: string;
  @JsonProperty('name', String)
  public name: string = undefined;
  @JsonProperty('customer', String)
  public customer: string;
  @JsonProperty('supplier', String)
  public supplier: string;
  @JsonProperty('investor', String)
  public investor: string;
  @JsonProperty('oneConnect', String)
  public oneConnect: string;
  @JsonProperty('stellarPublicKey', String)
  public stellarPublicKey: string = undefined;
}
