import { JsonObject, JsonProperty } from 'json2typescript';
import { AutoTradeOrder } from './auto-trade-order';
import { InvestorProfile } from './investor-profile';
import { Offer } from './offer';
import { Account } from './account';

@JsonObject('ExecutionUnit')
export class ExecutionUnit {
  @JsonProperty()
  public order: AutoTradeOrder = new AutoTradeOrder();
  @JsonProperty()
  public profile: InvestorProfile = new InvestorProfile();
  @JsonProperty()
  public offer: Offer = new Offer();
  @JsonProperty()
  public account: Account = new Account();
  @JsonProperty()
  public date: string = new Date().toISOString();

  // tslint:disable-next-line:member-ordering
  public static Success = 0;
  // tslint:disable-next-line:member-ordering
  public static ErrorInvalidTrade = 1;
// tslint:disable-next-line: member-ordering
  public static ErrorBadBid = 2;
}
