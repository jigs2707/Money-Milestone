import 'package:my_financial_goals/utils/languageString.dart';

extension AppString on String {
  String getFirebaseError() {
    if (contains("firebase_auth/invalid-credential")) {
      return LanguageStrings.lblIncorrectCredential;
    }
    else if (contains("firebase_auth/invalid-email")) {
      return LanguageStrings.lblIncorrectEmail;
    }
    else if (contains("firebase_auth/email-already-in-use")) {
      return LanguageStrings.lblEmailIsAlreadyUsed;
    }else{
      
    return this;
    }
  }
}
