import 'package:money_milestone/utils/currencyService.dart';
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

  String currency() {
    final amount = double.tryParse(this) ?? 0.0;
    final symbol = CurrencyService.instance.symbol;
    return '$symbol${amount.toStringAsFixed(2)}';
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
