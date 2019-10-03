import 'package:businesslibrary/stellar/sdk/ledger_response.dart';
import 'package:businesslibrary/stellar/sdk/offer_response.dart';

class TradeResponse {
  String id;
  String pagingToken;
  String ledgerCloseTime;
  String offerId;
  bool baseIsSeller;
  KeyPair baseAccount;
  String baseAmount;
  String baseAssetType;
  String baseAssetCode;
  String baseAssetIssuer;
  KeyPair counterAccount;
  String counterAmount;
  String counterAssetType;
  String counterAssetCode;
  String counterAssetIssuer;
  Links links;

  TradeResponse(
      this.id,
      this.pagingToken,
      this.ledgerCloseTime,
      this.offerId,
      this.baseIsSeller,
      this.baseAccount,
      this.baseAmount,
      this.baseAssetType,
      this.baseAssetCode,
      this.baseAssetIssuer,
      this.counterAccount,
      this.counterAmount,
      this.counterAssetType,
      this.counterAssetCode,
      this.counterAssetIssuer,
      this.links);
}

class Links {
  Link base;
  Link counter;
  Link operation;

  Links(this.base, this.counter, this.operation);
}
