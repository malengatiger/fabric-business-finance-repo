import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('AutoTradeOrder')
export class AutoTradeOrder {
  @JsonProperty('docType', String)
  public docType?: string;
  @JsonProperty('name', String)
  public name: string | undefined;
  @JsonProperty('autoTradeOrderId', String)
  public autoTradeOrderId: string | undefined;
  @JsonProperty('date', String)
  public date: string | undefined;
  @JsonProperty('investorName', String)
  public investorName: string | undefined;
  @JsonProperty('dateCancelled', String)
  public dateCancelled: string | undefined;
  @JsonProperty('wallet', String)
  public wallet: string | undefined;
  @JsonProperty('investorProfile', String)
  public investorProfile: string | undefined;
  @JsonProperty('user', String)
  public user: string | undefined;
  @JsonProperty('investor', String)
  public investor: string | undefined;
  @JsonProperty('isCancelled', Boolean)
  public isCancelled: boolean | undefined;
}
