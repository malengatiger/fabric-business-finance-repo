import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'Payment.g.dart';

@JsonSerializable()
class Payment extends Object with _$PaymentSerializerMixin {
  String seed;
  String sourceAccount;
  String destinationAccount;
  String amount;
  String memo, stringDate;
  String toFCMToken;
  String fromFCMToken;
  bool receiving, success;
  bool debug;
  int date;

  Payment(
      {@required this.seed,
      @required this.sourceAccount,
      @required this.destinationAccount,
      @required this.amount,
      @required this.memo,
      @required this.toFCMToken,
      @required this.fromFCMToken,
      this.receiving,
      @required this.date,
      @required this.stringDate,
      @required this.success,
      @required this.debug});

  factory Payment.fromJson(Map<dynamic, dynamic> json) =>
      _$PaymentFromJson(json);

  Payment.fromJSON(Map data) {
    this.seed = data['seed'];
    this.sourceAccount = data['sourceAccount'];
    this.destinationAccount = data['destinationAccount'];
    this.amount = data['amount'];
    this.memo = data['memo'];
    this.stringDate = data['stringDate'];
    this.toFCMToken = data['toFCMToken'];
    this.fromFCMToken = data['fromFCMToken'];
    this.receiving = data['receiving'];
    this.success = data['success'];
    this.debug = data['debug'];
    this.date = data['date'];
  }

  void printDetails() {
    print(
        "seed: sourceAccount: $sourceAccount $seed destination: $destinationAccount memo: $memo "
        "toFCM: $toFCMToken fromFCM: $fromFCMToken ");
  }
}
