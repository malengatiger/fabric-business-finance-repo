import 'package:businesslibrary/stellar/Record.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Embedded.g.dart';

@JsonSerializable()
class Embedded extends Object with _$EmbeddedSerializerMixin {
  List<Record> records;

  Embedded(this.records);

  List<Record> getRecords() {
    return this.records;
  }

  void setRecords(List<Record> records) {
    this.records = records;
  }

  factory Embedded.fromJson(Map<String, dynamic> json) =>
      _$EmbeddedFromJson(json);

  Embedded.fromJSON(Map data) {
    this.records = data['records'];
  }
}
