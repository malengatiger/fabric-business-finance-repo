import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('AutoTradeStart')
export class AutoTradeStart {
  @JsonProperty()
  public autoTradeStartId: string;
  @JsonProperty()
  public dateStarted: string;
  @JsonProperty()
  public docType: string;
  @JsonProperty()
  public dateEnded: string;
  @JsonProperty()
  public possibleTrades: number;
  @JsonProperty()
  public possibleAmount: number;
  @JsonProperty()
  public elapsedSeconds: number;
}
