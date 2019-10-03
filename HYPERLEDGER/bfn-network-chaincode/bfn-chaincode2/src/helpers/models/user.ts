
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('User')
export class User {

  @JsonProperty('docType', String)
  public docType?: string | undefined;
  @JsonProperty('userId', String)
  public userId: string | undefined;
  @JsonProperty('name', String)
  public name: string | undefined;
  @JsonProperty('cellphone', String)
  public cellphone: string | undefined;
  @JsonProperty('email', String)
  public email: string | undefined;
  @JsonProperty('dateRegistered', String)
  public dateRegistered: string;
  @JsonProperty('investor', String)
  public investor: string | undefined;
  @JsonProperty('customer', String)
  public customer: string | undefined;
  @JsonProperty('supplier', String)
  public supplier: string | undefined;
  @JsonProperty('isAdministrator', Boolean)
  public isAdministrator: boolean | false;
  @JsonProperty('auditor', String)
  public auditor: string | undefined;
  @JsonProperty('bank', String)
  public bank: string | undefined;
  @JsonProperty('oneConnect', String)
  public oneConnect: string | undefined;
  @JsonProperty('password', String)
  public password: string | undefined;

}
