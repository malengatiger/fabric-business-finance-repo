import 'package:businesslibrary/stellar/sdk/ledger_response.dart';
import 'package:businesslibrary/stellar/sdk/offer_response.dart';

class TransactionResponse {
  final String hash;
  final int ledger;
  final String createdAt;
  final KeyPair sourceAccount;
  final String pagingToken;
  final int sourceAccountSequence;
  final int feePaid;
  final int operationCount;
  final String envelopeXdr;
  final String resultXdr;
  final String resultMetaXdr;
  final Links links;

  TransactionResponse(
      this.hash,
      this.ledger,
      this.createdAt,
      this.sourceAccount,
      this.pagingToken,
      this.sourceAccountSequence,
      this.feePaid,
      this.operationCount,
      this.envelopeXdr,
      this.resultXdr,
      this.resultMetaXdr,
      this.links);
// Memo memo;

}

class Links {
  final Link account;
  final Link effects;
  final Link ledger;
  final Link operations;
  final Link precedes;
  final Link self;
  final Link succeeds;

  Links(this.account, this.effects, this.ledger, this.operations, this.precedes,
      this.self, this.succeeds);
}
