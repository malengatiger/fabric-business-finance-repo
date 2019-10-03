import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static Firestore _firestore = Firestore.instance;

  static const ErrorSignIn = 1,
      Success = 0,
      ErrorUserNotInDatabase = 2,
      ErrorDatabase = 3,
      ErrorNoOwningEntity = 4,
      CustomerType = 5,
      SupplierType = 6,
      InvestorType = 7;

  ///Existing user signs into BFN  and cahes data to SharedPrefs
  static Future<int> signIn(String email, String password) async {
    print(
        '🔑 🔑 🔑 SignIn.signIn ++++++++++++++++ 🍏 🍎 Firebase  $email $password +++++++');

    FirebaseUser fbUser;
    try {
      fbUser = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .catchError((e) {
        print(
            '👿 👿 👿 SignIn.signIn: ------------ 👿 👿 fucking *&%*fukIUHUB^!!  👿 ERROR! $e');
        throw e;
      });

      if (fbUser == null) {
        throw Exception('user is null 👿 👿 👿 ');
      }
    } catch (e) {
      print(
          '👿 👿 👿 SignIn.signIn:------------->>> 👿 👿 FIREBASE AUTHENTICATION ERROR - $e');
      throw e;
    }
    //get user from Firestore
    print('SignIn.signIn: ......... get user from Firestore');
    var querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments()
        .catchError((e) {
      print('SignIn.signIn ERROR $e');
      return ErrorDatabase;
    });
    User user;
    if (querySnapshot.documents.isNotEmpty) {
      user = new User.fromJson(querySnapshot.documents.first.data);
      await SharedPrefs.saveUser(user);
      return await getOwningEntity(user);
    } else {
      return ErrorUserNotInDatabase;
    }
  }

  static Future<int> getOwningEntity(User user) async {
    print(
        'SignIn.getOwningEntity: .... .....  ${user.firstName} ${user.lastName}');

    prettyPrint(user.toJson(), 'User: getOwningEntity');
    if (user.customer != null) {
      var partId = user.customer;
      var qSnap = await _firestore
          .collection('govtEntities')
          .where('participantId', isEqualTo: partId)
          .limit(1)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      Customer govtEntity;
      if (qSnap.documents.isNotEmpty) {
        govtEntity = new Customer.fromJson(qSnap.documents.first.data);
      }
      if (govtEntity == null) {
        print('SignIn.signIn ERROR  customer not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveCustomer(govtEntity);
      return Success;
    }

    if (user.supplier != null) {
      var partId = user.supplier;
      var qSnap = await _firestore
          .collection('suppliers')
          .where('participantId', isEqualTo: partId)
          .limit(1)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      Supplier supplier;
      if (qSnap.documents.isNotEmpty) {
        supplier = new Supplier.fromJson(qSnap.documents.first.data);
      }
      if (supplier == null) {
        print('SignIn.signIn ERROR  supplier not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveSupplier(supplier);
      return Success;
    }

    if (user.auditor != null) {
      var partId = user.auditor;
      var qSnap = await _firestore
          .collection('auditors')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      Auditor auditor;
      qSnap.documents.forEach((doc) {
        auditor = new Auditor.fromJson(doc.data);
      });
      if (auditor == null) {
        print('SignIn.signIn ERROR  auditor not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveAuditor(auditor);
      return Success;
    }
    if (user.procurementOffice != null) {
      var partId = user.procurementOffice;
      var qSnap = await _firestore
          .collection('procurementOffices')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      ProcurementOffice office;
      qSnap.documents.forEach((doc) {
        office = new ProcurementOffice.fromJson(doc.data);
      });
      if (office == null) {
        print('SignIn.signIn ERROR  office not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveProcurementOffice(office);
      return Success;
    }
    if (user.investor != null) {
      var partId = user.investor;
      var qSnap = await _firestore
          .collection('investors')
          .where('participantId', isEqualTo: partId)
          .limit(1)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      Investor investor;
      qSnap.documents.forEach((doc) {
        investor = new Investor.fromJson(doc.data);
      });
      if (investor == null) {
        print('SignIn.signIn ERROR  investor not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveInvestor(investor);
      return Success;
    }
    if (user.oneConnect != null) {
      var partId = user.oneConnect;
      var qSnap = await _firestore
          .collection('oneConnect')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      OneConnect one;
      qSnap.documents.forEach((doc) {
        one = new OneConnect.fromJson(doc.data);
      });
      if (one == null) {
        print('SignIn.signIn ERROR  OneConnect not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveOneConnect(one);
      return Success;
    }

    return ErrorDatabase;
  }
}
