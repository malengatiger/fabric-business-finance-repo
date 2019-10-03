import 'package:businesslibrary/stellar/Effects.dart';
import 'package:businesslibrary/stellar/Precedes.dart';
import 'package:businesslibrary/stellar/Self2.dart';
import 'package:businesslibrary/stellar/Succeeds.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Links2.g.dart';

@JsonSerializable()
class Links2 extends Object with _$Links2SerializerMixin {
  Self2 self;
//  Transaction transaction;
  Effects effects;
  Succeeds succeeds;
  Precedes precedes;

  Links2(this.self, this.effects, this.succeeds, this.precedes);
  factory Links2.fromJson(Map<String, dynamic> json) => _$Links2FromJson(json);
}
