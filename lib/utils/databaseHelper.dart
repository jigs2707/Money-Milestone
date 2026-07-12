class DatabaseHelper {
  //
  //Collection names
  static const usersCollectionName = "users";
  static const goalsCollectionName = "goals";
  static const transactionsCollectionName = "transactions";

  //--------------------------------- Collections Keys
  static const userNameKey = "name";
  static const currencyKey = "currency_code";
  static const currentStreakKey = "current_streak";
  static const longestStreakKey = "longest_streak";
  static const lastDepositDateKey = "last_deposit_date";

  //
  static const categoriesCollection = "categories";
  static const goalCategoryKey = "category_id";

  static const goalAmountKey = "goal_amount";
  static const goalNameKey = "goal_name";
  static const goalDate = "goal_date";
  static const goalSavedAmount = "goal_saved_amount";

  //
  static const transactionNote = "note";
  static const transactionDate = "date";
  static const transactionAmount = "amount";
  static const transactionType = "type";
  static const transactionId="id";

  //--------------------------------- App Config
  static const appConfigCollectionName = "app_config";
  static const appConfigDocName = "version";
  static const latestVersionKey = "latest_version";
  static const isForceUpdateKey = "is_force_update";
  static const storeUrlKey = "store_url";

  //--------------------------------- Session Tracking
  static const appSessionsCollection = "app_sessions";
  static const sessionUserId = "user_id";
  static const sessionOpenedAt = "opened_at";
  static const sessionDate = "date";       // "YYYY-MM-DD" for easy daily queries
  static const sessionType = "type";       // "app_open" | "background_resume"
  static const sessionPlatform = "platform"; // "android" | "ios"
}
