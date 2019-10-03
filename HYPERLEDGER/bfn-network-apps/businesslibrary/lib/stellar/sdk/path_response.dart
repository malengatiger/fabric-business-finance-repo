import 'package:businesslibrary/stellar/sdk/ledger_response.dart';
import 'package:businesslibrary/stellar/sdk/offer_response.dart';

class PathResponse {
  String destinationAmount;
  String destinationAssetType;
  String destinationAssetCode;
  String destinationAssetIssuer;
  String sourceAmount;
  String sourceAssetType;
  String sourceAssetCode;
  String sourceAssetIssuer;
  List<Asset> path;
  Links links;

  PathResponse(
      this.destinationAmount,
      this.destinationAssetType,
      this.destinationAssetCode,
      this.destinationAssetIssuer,
      this.sourceAmount,
      this.sourceAssetType,
      this.sourceAssetCode,
      this.sourceAssetIssuer,
      this.path,
      this.links);
}

class Links {
  Link self;

  Links(this.self);
}
