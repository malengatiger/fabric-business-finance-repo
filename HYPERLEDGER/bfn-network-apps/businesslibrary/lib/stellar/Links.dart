import 'package:businesslibrary/stellar/Data.dart';
import 'package:businesslibrary/stellar/Effects.dart';
import 'package:businesslibrary/stellar/Offers.dart';
import 'package:businesslibrary/stellar/Operations.dart';
import 'package:businesslibrary/stellar/Payments.dart';
import 'package:businesslibrary/stellar/Self.dart';
import 'package:businesslibrary/stellar/Trades.dart';
import 'package:businesslibrary/stellar/Transactions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Links.g.dart';

@JsonSerializable()
class Links extends Object with _$LinksSerializerMixin {
  Self self;

  Self getSelf() {
    return this.self;
  }

  void setSelf(Self self) {
    this.self = self;
  }

  Transactions transactions;

  Transactions getTransactions() {
    return this.transactions;
  }

  void setTransactions(Transactions transactions) {
    this.transactions = transactions;
  }

  Operations operations;

  Operations getOperations() {
    return this.operations;
  }

  void setOperations(Operations operations) {
    this.operations = operations;
  }

  Payments payments;

  Payments getPayments() {
    return this.payments;
  }

  void setPayments(Payments payments) {
    this.payments = payments;
  }

  Effects effects;

  Effects getEffects() {
    return this.effects;
  }

  void setEffects(Effects effects) {
    this.effects = effects;
  }

  Offers offers;

  Offers getOffers() {
    return this.offers;
  }

  void setOffers(Offers offers) {
    this.offers = offers;
  }

  Trades trades;

  Trades getTrades() {
    return this.trades;
  }

  void setTrades(Trades trades) {
    this.trades = trades;
  }

  Data data;

  Data getData() {
    return this.data;
  }

  void setData(Data data) {
    this.data = data;
  }

  Links(this.self, this.transactions, this.operations, this.payments,
      this.effects, this.offers, this.trades, this.data);
  factory Links.fromJson(Map<String, dynamic> json) => _$LinksFromJson(json);
}
