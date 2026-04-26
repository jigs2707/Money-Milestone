import 'package:hive/hive.dart';

class HiveRepository {
  static String authStatusBoxKey = "authStatus";
  static String userDetailBoxKey = "userDetailsBox";
  static String settingsBoxKey = "settingsBox";
  static String badgesBoxKey = "badgesBox";

  ///--------------------------------- authStatusBox Keys
  ///
  static String isAuthenticatedKey = "isAuthenticated";

  ///--------------------------------- settingsBox Keys
  ///
  static String isDarkModeKey = "isDarkMode";

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

  ///--------------------------------- settingsBox methods

  static bool get isDarkMode =>
      Hive.box(settingsBoxKey).get(isDarkModeKey) ?? false;

  static set setDarkMode(bool value) =>
      Hive.box(settingsBoxKey).put(isDarkModeKey, value);

  ///---------------------------------general methods
  ///
  static Future<void> init() async {
    await Hive.openBox(authStatusBoxKey);
    await Hive.openBox(userDetailBoxKey);
    await Hive.openBox(settingsBoxKey);
    await Hive.openBox(badgesBoxKey);
  }

  /// Returns true if this badge key has already been celebrated
  static bool isBadgeSeen(String badgeKey) =>
      Hive.box(badgesBoxKey).get(badgeKey) == true;

  /// Marks a badge as celebrated so it won't show again
  static Future<void> markBadgeSeen(String badgeKey) =>
      Hive.box(badgesBoxKey).put(badgeKey, true);

  /// Resets all badge celebration data (useful for testing)
  static Future<void> clearBadges() =>
      Hive.box(badgesBoxKey).clear();

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
