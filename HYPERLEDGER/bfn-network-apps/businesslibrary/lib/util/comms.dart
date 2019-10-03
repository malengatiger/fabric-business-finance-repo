import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/stellar/Account.dart';
import 'package:businesslibrary/stellar/Record.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';

class StellarCommsUtil {
  static const DEBUG_URL_PREFIX = "https://horizon-testnet.stellar.org/";
  static const PROD_URL_PREFIX = "https://horizon.stellar.org/";

  static Future<Account> getAccount(String accountID) async {
    assert(accountID != null);
    print('StellarCommsUtil.getAccount &&&&& getting account details ...');
    var url;
    if (isInDebugMode) {
      url = DEBUG_URL_PREFIX;
    } else {
      url = PROD_URL_PREFIX;
    }
    url += "accounts/" + accountID;
    print("account url: " + url);
    var httpClient = new HttpClient();

    Account acct;
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var statusCode = response.statusCode;
    print("****************** Stellar HTTP status code: $statusCode");
    if (response.statusCode == 200) {
      var jx = await response.transform(utf8.decoder).join();
      Map data = json.decode(jx);
      acct = new Account.fromJson(data);
      print(
          "****************  Stellar Account from network: ${data['account_id']}");
      prettyPrint(data, 'Details of Stellar Account: ################ &&: ');
    } else {
      var msg = 'Bad Stellar HTTP status code: ${response.statusCode}';
      print(msg);
      throw (msg);
    }

    return acct;
  }

  static const LIMIT = 200;
  static const ORDER = "desc";

  static Future<List<Record>> getPayments(String accountID) async {
    //GET https://horizon-testnet.stellar.org/payments?limit=5&order=desc
    Map map = new Map();
    map["order"] = "desc";
    map["limit"] = 1000;

    assert(accountID != null);
    var url;
    if (isInDebugMode) {
      url = DEBUG_URL_PREFIX +
          "accounts/$accountID/payments?limit=$LIMIT&order=$ORDER";
    } else {
      url = PROD_URL_PREFIX +
          "accounts/$accountID/payments?limit=$LIMIT&order=$ORDER";
    }

    print("payments url: " + url);
    var httpClient = new HttpClient();

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var statusCode = response.statusCode;
      print("getPayments Stellar HTTP status code: $statusCode");
      if (response.statusCode == HttpStatus.OK) {
        var jsonData = await response.transform(utf8.decoder).join();
//        var s = jsonData.replaceAll(",", ",\n");
//        print('Communications.getPayments  jsondata: $s');
        Map data = json.decode(jsonData);
//        print('Communications.getPayments data: $data');
//        var links = data['_links'];
        var emb = data['_embedded'];

//        print('links $links');
//        print('emb $emb');

        List list = emb['records'];
        List<Record> records = new List();
        list.forEach((val) {
          var mLinks = new List();
          Map links = val['_links'];
          links.forEach((key, val) {
            var mlink = new StellarLink(key, val['href']);
            mLinks.add(mlink);
//            print('mlink: ${mlink.printInfo()}');
          });
          try {
            var rec = new Record.fromJson(val);
            rec.mLinks = mLinks;
            records.add(rec);
//            print(rec.toJson());
          } catch (e) {
            print('%%%%%%%%% ERROR');
          }
        });
        return records;
      } else {
        return null;
      }
    } catch (exception) {
      return exception;
    }
  }

  static Future<Account> getAccountNotAsync(String accountID) async {
    assert(accountID != null);
    print(
        'StellarCommsUtil.getAccountNotAsync &&&&& getting account details ...');
    var url;
    if (isInDebugMode) {
      url = DEBUG_URL_PREFIX;
    } else {
      url = PROD_URL_PREFIX;
    }
    url += "accounts/" + accountID;
    print("account url: " + url);
    var httpClient = new HttpClient();

    Account acct;
    httpClient.getUrl(Uri.parse(url)).then((request) {
      request.close().then((response) {
        var statusCode = response.statusCode;
        print(
            "StellarCommsUtil.getAccountNotAsync:  ****************** Stellar HTTP status code: $statusCode");
        if (response.statusCode == 200) {
          response.transform(utf8.decoder).join().then((jx) {
            Map data = json.decode(jx);
            acct = new Account.fromJson(data);
            print(
                "StellarCommsUtil.getAccountNotAsync: ****************  Stellar Account from network:"
                "\n\n ${data['account_id']}");
            prettyPrint(
                data, 'Details of Stellar Account: ################ &&: ');
            return acct;
          });
        } else {
          var msg = 'Bad Stellar HTTP status code: ${response.statusCode}';
          print(msg);
          throw (msg);
        }
      });
    });
    return null;
  }
}
