import 'package:businesslibrary/stellar/Record.dart';
import 'package:json_annotation/json_annotation.dart';

part 'RecordsBag.g.dart';

@JsonSerializable()
class RecordsBag extends Object with _$RecordsBagSerializerMixin {
  List<Record> payments;

  RecordsBag(this.payments);
  factory RecordsBag.fromJson(Map<String, dynamic> json) =>
      _$RecordsBagFromJson(json);

  RecordsBag.create();
}
