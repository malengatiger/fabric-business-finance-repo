
import { JsonObject, JsonProperty } from 'json2typescript';

@JsonObject('Sector')
export class Sector {

  @JsonProperty('docType', String)
  public docType?: string | undefined;

  @JsonProperty('sectorId', String)
  public sectorId: string | undefined;

  @JsonProperty('sectorName', String)
  public sectorName: string | undefined;

}
