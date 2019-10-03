import { JsonObject, JsonProperty } from 'json2typescript';
import { AutoTradeOrder } from './auto-trade-order';
import { InvestorProfile } from './investor-profile';
import { Offer } from './offer';

@JsonObject('ExecutionUnit')
export class ExecutionUnit {
  @JsonProperty()
  public order: AutoTradeOrder | undefined;
  @JsonProperty()
  public profile: InvestorProfile | undefined;
  @JsonProperty()
  public offer: Offer | undefined;
  @JsonProperty()
  public account: Account | undefined;
  @JsonProperty()
  public date: string | undefined;

  // tslint:disable-next-line:member-ordering
  public static Success = 0;
  // tslint:disable-next-line:member-ordering
  public static ErrorInvalidTrade = 1;
// tslint:disable-next-line: member-ordering
  public static ErrorBadBid = 2;
}
