
import 'package:money_milestone/utils/constant.dart';
import 'package:money_milestone/utils/languageString.dart';

extension AppString on String {
  String getFirebaseError() {
    if (contains("firebase_auth/invalid-credential")) {
      return LanguageStrings.lblIncorrectCredential;
    } else if (contains("firebase_auth/invalid-email")) {
      return LanguageStrings.lblIncorrectEmail;
    } else if (contains("firebase_auth/email-already-in-use")) {
      return LanguageStrings.lblEmailIsAlreadyUsed;
    } else if (contains("firebase_auth/weak-password")) {
      return LanguageStrings.lblPasswordMustBeOfSixCharcter;
    }
    return this;
  }

  currency() {
    double amount = double.parse(this);
    return "${Constant.currencySymbol}${amount.toStringAsFixed(Constant.numberOfDecimalPointAfterAmount)}";
  }

  toDouble() {
    return double.parse(this);
  }
  toInt() {
    return int.parse(this);
  }

  toCapitalize() {
    if (length > 0) {
      return "${this[0].toUpperCase()}${substring(1, length)}";
    }
    return this;
  }
}
