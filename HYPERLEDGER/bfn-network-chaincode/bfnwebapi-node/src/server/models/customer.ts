
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Customer')
export class Customer {

  @JsonProperty('docType', String)
  public docType?: string | undefined;
  @JsonProperty('participantId', String)
  public participantId: string | undefined;
  @JsonProperty('name', String)
  public name: string | undefined;
  @JsonProperty('cellphone', String)
  public cellphone: string | undefined;
  @JsonProperty('email', String)
  public email: string | undefined;
  @JsonProperty('documentReference', String)
  public documentReference: string | undefined;
  @JsonProperty('description', String)
  public description: string | undefined;
  @JsonProperty('address', String)
  public address: string | undefined;
  @JsonProperty('dateRegistered', String)
  public dateRegistered: string | undefined;
  @JsonProperty('sector', String)
  public sector: string | undefined;
  @JsonProperty('country', String)
  public country: string | undefined;
}
