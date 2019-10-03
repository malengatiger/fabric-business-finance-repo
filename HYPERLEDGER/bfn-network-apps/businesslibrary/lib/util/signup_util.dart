import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';

class SignUp {
  static const ErrorBlockchain = 3,
      ErrorMissingOrInvalidData = 4,
      ErrorFirebaseUserExists = 5,
      ErrorFireStore = 6,
      Success = 0,
      ErrorCreatingFirebaseUser = 7;

  static Future signUpSupplier(Supplier supplier, User admin) async {
    throw Exception('not cooked yet');
  }
}
