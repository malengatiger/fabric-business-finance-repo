class AccountResponse {
  //org_stellar_sdk_KeyPair keypair;
  String id;
  int sequenceNumber;
  String pagingToken;
  int subentryCount;
  String inflationDestination;
  String homeDomain;
  Thresholds thresholds;
  Flags flags;
  List<Balance> balances;
  List<Signer> signers;
  Links links;

  AccountResponse(
      this.id,
      this.sequenceNumber,
      this.pagingToken,
      this.subentryCount,
      this.inflationDestination,
      this.homeDomain,
      this.thresholds,
      this.flags,
      this.balances,
      this.signers,
      this.links);
}

class Thresholds {
  int lowThreshold;
  int medThreshold;
  int highThreshold;

  Thresholds(this.lowThreshold, this.medThreshold, this.highThreshold);
}

class Flags {
  bool authRequired;
  bool authRevocable;

  Flags(this.authRequired, this.authRevocable);
}

class Balance {
  String assetType;
  String assetCode;
  String assetIssuer;
  String limit;
  String balance;

  Balance(this.assetType, this.assetCode, this.assetIssuer, this.limit,
      this.balance);
}

class Signer {
  String accountId;
  int weight;

  Signer(this.accountId, this.weight);
}

class Links {
  Link effects;
  Link offers;
  Link operations;
  Link self;
  Link transactions;

  Links(
      this.effects, this.offers, this.operations, this.self, this.transactions);
}

class Link {
  String href;
  bool templated;

  Link(this.href, this.templated);
}
