class LedgerResponse {
  int sequence;
  String hash;
  String pagingToken;
  String prevHash;
  int transactionCount;
  int operationCount;
  String closedAt;
  String totalCoins;
  String feePool;
  int baseFee;
  String baseReserve;
  String baseFeeInStroops;
  String baseReserveInStroops;
  int maxTxSetSize;
  Links links;

  LedgerResponse(
      this.sequence,
      this.hash,
      this.pagingToken,
      this.prevHash,
      this.transactionCount,
      this.operationCount,
      this.closedAt,
      this.totalCoins,
      this.feePool,
      this.baseFee,
      this.baseReserve,
      this.baseFeeInStroops,
      this.baseReserveInStroops,
      this.maxTxSetSize,
      this.links);
}

class Links {
  Link effects;
  Link operations;
  Link self;
  Link transactions;

  Links(this.effects, this.operations, this.self, this.transactions);
}

class Link {
  String href;
  bool templated;

  Link(this.href, this.templated);
}
