import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject("Balance")
export class Balance {
  @JsonProperty()
  public balance: string | undefined;
  @JsonProperty()
  public asset_type: string | undefined;
}
@JsonObject("Account")
export class Account {
  @JsonProperty()
  public id: string | undefined;
  @JsonProperty()
  public paging_token: string | undefined;
  @JsonProperty()
  public account_id: string | undefined;
  @JsonProperty()
  public sequence: string | undefined;
  @JsonProperty()
  public balances: Balance[] | undefined;
}
