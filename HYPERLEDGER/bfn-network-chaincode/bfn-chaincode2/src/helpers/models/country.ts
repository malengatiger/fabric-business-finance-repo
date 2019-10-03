
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Country')
export class Country {

  @JsonProperty('docType', String)
  public docType?: string | undefined;
  @JsonProperty('countryId', String)
  public countryId: string | undefined;
  @JsonProperty('code', String)
  public code: string | undefined;
  @JsonProperty('name', String)
  public name: string | undefined;
  @JsonProperty('vat', Number)
  public vat: number | 0.0;

}
