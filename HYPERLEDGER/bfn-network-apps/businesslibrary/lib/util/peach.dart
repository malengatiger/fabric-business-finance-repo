import 'dart:convert';

import 'package:businesslibrary/util/lookups.dart';
import 'package:crypt/crypt.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

//

class Peach {
  static const PEACH_PAYMENT_KEY_URL = 'https://eft.ppay.io/api/v1/payment-key';
  static const PEACH_PAYMENT_URL = 'https://eft.ppay.io/eft?payment_key=';
  static const userName = 'malengadev';
  static const password = 'kkTiger3';
  static const salt = 'OneConnectBFNsalt';
  static String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$userName:$password'));

  static Map<String, String> headers = {
    'Content-type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
    'authorization': basicAuth,
  };

  static Future<PaymentKey> getPaymentKey({PeachPayment payment}) async {
    print('Peach.getPaymentKey ##########################################');
    //payment.setHash();
    prettyPrint(payment.toJson(), 'payment to get a key for:');
    var start = DateTime.now();

    Map<String, dynamic> body = {
      'merchant_reference': payment.merchantReference,
      'amount': payment.amount.toStringAsFixed(2),
      'success_url': payment.successURL,
      'error_url': payment.errorUrl,
      'cancel_url': payment.cancelUrl,
      'notify_url': payment.notifyUrl,
    };

    print('basicAuth: $basicAuth}');
    print('userName: $userName userName: $password');
    print('usrl: $PEACH_PAYMENT_KEY_URL');
    prettyPrint(headers, '## headers: ');
    prettyPrint(body, '@@@@@@@@@@@@@@ sending to Peach ....');
    var client = new http.Client();
    var resp = await client
        .post(
      PEACH_PAYMENT_KEY_URL,
      body: body,
      headers: headers,
    )
        .whenComplete(() {
      client.close();
    });
    print(
        '\n\nPeach.getPaymentKey .... ################ Peach Payments: status: ${resp.statusCode}');
    if (resp.body.contains('DOCTYPE')) {
      print('Peach.getPaymentKey --- HTML returned - no sweat. maybe.');
    } else {
      print('########### RESPONSE from Peach');
      print(resp.body);
    }
    var end = DateTime.now();
    print(
        'Peach.getPaymentKey ### elapsed: ${end.difference(start).inSeconds} seconds');
    if (resp.statusCode == 200) {
      var key = PaymentKey.fromJson(json.decode(resp.body));
      return key;
    } else {
      var map = json.decode(resp.body);
      throw Exception('Payment Key request failed: ${map['message']}');
    }
  }
}

class PeachNotification {
  String callpay_transaction_id,
      success,
      amount,
      created,
      reason,
      user,
      merchant_reference,
      gateway_reference,
      organisation_id,
      gateway_response,
      currency,
      payment_key;

  PeachNotification(
      this.callpay_transaction_id,
      this.success,
      this.amount,
      this.created,
      this.reason,
      this.user,
      this.merchant_reference,
      this.gateway_reference,
      this.organisation_id,
      this.gateway_response,
      this.currency,
      this.payment_key);

  PeachNotification.fromJson(Map data) {
    this.callpay_transaction_id = data['callpay_transaction_id'];
    this.success = data['success'];
    this.amount = data['amount'];
    this.created = data['created'];
    this.reason = data['reason'];
    this.user = data['user'];
    this.merchant_reference = data['merchant_reference'];
    this.gateway_reference = data['gateway_reference'];
    this.organisation_id = data['organisation_id'];
    this.gateway_response = data['gateway_response'];
    this.currency = data['currency'];
    this.payment_key = data['payment_key'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'callpay_transaction_id': callpay_transaction_id,
        'success': success,
        'amount': amount,
        'created': created,
        'reason': reason,
        'user': user,
        'merchant_reference': merchant_reference,
        'gateway_reference': gateway_reference,
        'organisation_id': organisation_id,
        'gateway_response': gateway_response,
        'currency': currency,
        'payment_key': payment_key,
      };
}

class PaymentKey {
  String key, url;
  PaymentKey(this.key, this.url);

  PaymentKey.fromJson(Map data) {
    this.key = data['key'];
    this.url = data['url'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'url': url,
      };
}

class PeachPayment {
  String beneficiaryAccountNumber,
      beneficiaryName,
      beneficiaryAccountType, //[cheque, savings, transmission]
      customParameters,
      beneficiaryBank;
  double amount;
  String successURL,
      errorUrl,
      cancelUrl,
      notifyUrl,
      merchantReference,
      defaultBeneficiaryReference,
      hash;
  List<String> paymentTypes;

  PeachPayment(
      {this.beneficiaryAccountNumber,
      this.beneficiaryName,
      this.beneficiaryAccountType,
      this.beneficiaryBank,
      this.amount,
      this.successURL,
      this.errorUrl,
      this.cancelUrl,
      this.notifyUrl,
      this.customParameters,
      this.merchantReference,
      this.hash,
      this.defaultBeneficiaryReference,
      this.paymentTypes}); //null defaults to EFT

  PeachPayment.fromJson(Map data) {
    this.beneficiaryAccountNumber = data['beneficiaryAccountNumber'];
    this.beneficiaryName = data['beneficiaryName'];
    this.beneficiaryAccountType = data['beneficiaryAccountType'];
    this.beneficiaryBank = data['beneficiaryBank'];

    this.amount = data['amount'];
    this.merchantReference = data['merchantReference'];
    this.paymentTypes = data['paymentTypes'];
    this.successURL = data['successURL'];
    this.errorUrl = data['errorUrl'];
    this.cancelUrl = data['cancelUrl'];
    this.notifyUrl = data['notifyUrl'];
    this.defaultBeneficiaryReference = data['defaultBeneficiaryReference'];
    this.hash = data['hash'];
    this.customParameters = data['customParameters'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'beneficiaryAccountNumber': beneficiaryAccountNumber,
        'beneficiaryName': beneficiaryName,
        'beneficiaryAccountType': beneficiaryAccountType,
        'beneficiaryBank': beneficiaryBank,
        'amount': amount,
        'merchantReference': merchantReference,
        'paymentTypes': paymentTypes,
        'successURL': successURL,
        'errorUrl': errorUrl,
        'cancelUrl': cancelUrl,
        'notifyUrl': notifyUrl,
        'defaultBeneficiaryReference': defaultBeneficiaryReference,
        'hash': hash,
        'customParameters': customParameters,
      };

  void setHash() {
    String m = beneficiaryAccountNumber +
        '.' +
        beneficiaryName +
        '.' +
        beneficiaryAccountType +
        '.' +
        beneficiaryBank +
        '.' +
        Peach.salt;
    m = m.toLowerCase();
    print(m);
    var bytes = utf8.encode(m); // data being hashed

    Digest digest = sha256.convert(bytes);

    print("\n\n######### Digest as bytes: ${digest.bytes}");
    print("######### Digest as hex string: $digest");
    print("######### Digest as string: ${digest.toString()}");
    hash = digest.toString();
    String mx = beneficiaryAccountNumber +
        beneficiaryName +
        beneficiaryAccountType +
        beneficiaryBank;
    final c3 = new Crypt.sha256(mx, salt: Peach.salt);
    print("######### Crypt as string: ${c3.toString()}");

    final c4 = new Crypt.sha256(m);
    print("######### Crypt as string, without salt: ${c4.toString()}\n\n");
    hash = digest.toString();
  }
}
