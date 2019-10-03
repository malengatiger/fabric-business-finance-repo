class TradeAggregationResponse {
  int timestamp;
  int tradeCount;
  String baseVolume;
  String counterVolume;
  String avg;
  String high;
  String low;
  String open;
  String close;

  TradeAggregationResponse(this.timestamp, this.tradeCount, this.baseVolume,
      this.counterVolume, this.avg, this.high, this.low, this.open, this.close);
}
