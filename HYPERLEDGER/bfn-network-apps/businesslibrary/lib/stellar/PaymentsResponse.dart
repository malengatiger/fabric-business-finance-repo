import 'package:businesslibrary/stellar/Embedded.dart';
import 'package:businesslibrary/stellar/Links.dart';
import 'package:json_annotation/json_annotation.dart';

part 'PaymentsResponse.g.dart';

@JsonSerializable()
class PaymentsResponse extends Object with _$PaymentsResponseSerializerMixin {
  Links links;
  Embedded embedded;

  PaymentsResponse(this.links, this.embedded);
  factory PaymentsResponse.fromJson(Map json) =>
      _$PaymentsResponseFromJson(json);

  PaymentsResponse.fromJSON(Map data) {
    this.embedded = new Embedded.fromJSON(data['_embedded']);
    this.links = new Links.fromJson(data['_links']);
  }
}
