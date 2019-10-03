import 'package:json_annotation/json_annotation.dart';
part 'Thresholds.g.dart';
@JsonSerializable()

class Thresholds extends Object with _$ThresholdsSerializerMixin{
  int low_threshold;


  Thresholds(this.low_threshold, this.med_threshold, this.high_threshold);
  factory Thresholds.fromJson(Map<String, dynamic> json) => _$ThresholdsFromJson(json);


  int getLowThreshold() {
    return this.low_threshold;
  }

  void setLowThreshold(int low_threshold) {
    this.low_threshold = low_threshold;
  }

  int med_threshold;

  int getMedThreshold() {
    return this.med_threshold;
  }

  void setMedThreshold(int med_threshold) {
    this.med_threshold = med_threshold;
  }

  int high_threshold;

  int getHighThreshold() {
    return this.high_threshold;
  }

  void setHighThreshold(int high_threshold) {
    this.high_threshold = high_threshold;
  }
}
