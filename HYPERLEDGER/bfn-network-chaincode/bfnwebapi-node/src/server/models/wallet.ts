import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Wallet')
export class Wallet {
  @JsonProperty('docType', String)
  public docType?: string;

  @JsonProperty('dateRegistered', String)
  public dateRegistered: string | undefined;
  @JsonProperty('name')
  public name: string | undefined;
  @JsonProperty('customer', String)
  public customer: string | undefined;
  @JsonProperty('supplier', String)
  public supplier: string | undefined;
  @JsonProperty('investor', String)
  public investor: string | undefined;
  @JsonProperty('oneConnect', String)
  public oneConnect: string | undefined;
  @JsonProperty('stellarPublicKey')
  public stellarPublicKey: string | undefined
}
