
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Customer')
export class Customer {

  @JsonProperty('docType', String)
  public docType?: string;
  @JsonProperty('participantId', String)
  public participantId: string;
  @JsonProperty('name', String)
  public name: string | undefined;
  @JsonProperty('cellphone', String)
  public cellphone: string;
  @JsonProperty('email', String)
  public email: string | undefined;
  @JsonProperty('documentReference', String)
  public documentReference: string;
  @JsonProperty('description', String)
  public description: string;
  @JsonProperty('address', String)
  public address: string;
  @JsonProperty('dateRegistered', String)
  public dateRegistered: string;
  @JsonProperty('sector', String)
  public sector: string;
  @JsonProperty('country', String)
  public country: string | undefined;
}
