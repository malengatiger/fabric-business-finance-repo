
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Supplier')
export class Supplier {

  @JsonProperty('docType')
  public docType?: string;

  @JsonProperty('participantId')
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
