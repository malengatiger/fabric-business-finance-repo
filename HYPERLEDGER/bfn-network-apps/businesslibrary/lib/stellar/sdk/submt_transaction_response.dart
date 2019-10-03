class SubmitTransactionResponse {
  final String hash;
  final int ledger;
  final String envelopeXdr;
  final String resultXdr;
  final Extras extras;

  SubmitTransactionResponse(
      this.hash, this.ledger, this.envelopeXdr, this.resultXdr, this.extras);
}

class Extras {
  final String envelopeXdr;
  final String resultXdr;
  final ResultCodes resultCodes;

  Extras(this.envelopeXdr, this.resultXdr, this.resultCodes);
}

class ResultCodes {
  final String transactionResultCode;
  final List<String> operationsResultCodes;

  ResultCodes(this.transactionResultCode, this.operationsResultCodes);
}
