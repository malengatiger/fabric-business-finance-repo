import { JsonObject, JsonProperty } from "json2typescript";

@JsonObject("WalletCache")
export class WalletCache {
  @JsonProperty()
  _id: string = '';
  @JsonProperty()
  userContent: string = '';
  @JsonProperty()
  privateKey: string = '';
  @JsonProperty()
  publicKey: string = '';
  @JsonProperty()
  date: string = new Date().toISOString();
  @JsonProperty()
  secret: string = ''
  @JsonProperty()
  userFileName: string = ''
  @JsonProperty()
  publicKeyFileName: string = ''
  @JsonProperty()
  privateKeyFileName: string = ''

  public toJson() {
    return {
      _id: this._id,
      userContent: this.userContent,
      privateKey: this.privateKey,
      publicKey: this.publicKey,
      date: this.date,
      secret: this.secret,
      publicKeyFileName: this.publicKeyFileName,
      privateKeyFileName: this.privateKeyFileName,
      userFileName: this.userFileName 
    }
  }
  public fromJson(json: any) {
    this._id = json._id;
    this.date = json.date;
    this.userContent = json.userContent;
    this.privateKey = json.privateKey;
    this.publicKey = json.publicKey;
    this.secret = json.secret;
    this.userFileName = json.userFileName;
    this.publicKeyFileName = json.publicKeyFileName;
    this.privateKeyFileName = json.privateKeyFileName;
  }
  
}