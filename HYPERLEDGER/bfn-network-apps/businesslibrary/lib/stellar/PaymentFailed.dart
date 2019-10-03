import 'package:json_annotation/json_annotation.dart';
part 'PaymentFailed.g.dart';
@JsonSerializable()

class PaymentFailed extends Object with _$PaymentFailedSerializerMixin{
  String fcmToken,destinationAccount, sourceAccount,amount,memo,error,stringDate;
  int date;


  PaymentFailed(this.fcmToken, this.destinationAccount, this.sourceAccount,
      this.amount, this.memo, this.error, this.stringDate, this.date);

  factory PaymentFailed.fromJson(Map<String, dynamic> json) => _$PaymentFailedFromJson(json);


}