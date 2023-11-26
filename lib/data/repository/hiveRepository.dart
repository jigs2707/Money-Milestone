import 'package:hive/hive.dart';

class HiveRepository {
  //box-keys
  static String authStatusBoxKey = "authStatus";
  static String userDetailBoxKey = "userDetailsBox";

  ///--------------------------------- authStatusBox Keys
  ///
  static String isAuthenticatedKey = "isAuthenticated";

  ///--------------------------------- userDetailBox Keys
  ///
  static String userIdKey = "id";
  static String userNameKey = "username";

  ///--------------------------------- userDetailBox methods

  static String? get getUsername => Hive.box(userDetailBoxKey).get(userNameKey);

  static set setUsername(username) =>
      Hive.box(userDetailBoxKey).put(userNameKey, username);

  static String? get getUserId => Hive.box(userDetailBoxKey).get(userIdKey);

  static set setUserId(username) =>
      Hive.box(userDetailBoxKey).put(userIdKey, username);

  ///--------------------------------- authStatusBox methods

  static bool get isUserLoggedIn =>
      Hive.box(authStatusBoxKey).get(isAuthenticatedKey) ?? false;

  static set setUserLoggedIn(enable) =>
      Hive.box(authStatusBoxKey).put(isAuthenticatedKey, enable);

  ///---------------------------------general methods
  ///
  static Future<void> init() async {
    await Hive.openBox(authStatusBoxKey);
    await Hive.openBox(userDetailBoxKey);
  }

  //
  static dynamic getAllValueOf({required String boxName}) {
    return Hive.box(boxName).toMap();
  }

  static Future<void> putAllValue(
      {required String boxName, required Map<dynamic, dynamic> values}) async {
    await Hive.box(boxName).putAll(values);
  }

  static Future<void> clearBoxValues({required String boxName}) async {
    await Hive.box(boxName).clear();
  }
}
