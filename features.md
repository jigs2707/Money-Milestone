# Money Milestone — Feature Reference

---

## 1. Authentication

### Sign Up
Create a new account with email and password. A verification email is sent immediately after registration.

**Edge conditions:**
- Duplicate email address shows a Firebase auth error toast.
- Weak passwords (under 6 characters) are rejected by Firebase before hitting the server.
- User is not navigated to the home screen until email is verified.

### Log In
Email + password login. Navigates to the home screen on success and loads the user's saved currency.

**Edge conditions:**
- Wrong credentials surface a human-readable Firebase error (mapped via `getFirebaseError()`).
- If the account was deleted on the Firebase side, login fails gracefully.

### Forgot Password
A bottom sheet with an email field. Sends a Firebase password-reset email.

**Edge conditions:**
- Empty email field is caught client-side before the API call.
- If the email doesn't exist in Firebase, the error is shown in the sheet (not a full-screen crash).
- Sheet keyboard avoidance is reactive — no overflow even when the soft keyboard is fully open.

### Email Verification
After sign-up the user is held on a verification screen until they confirm their email.

**Edge conditions:**
- The screen polls/checks verification status; unverified users cannot access goals data.

---

## 2. Goal Management

### Create a Goal
Add a savings goal with a name, target amount, deadline date, and category. Opened from the home screen "Add Goal" button or the empty-state CTA.

**Edge conditions:**
- All fields are required — the save button is blocked if name, amount, or date is empty.
- Amount must be a valid positive number.
- Deadline date is mandatory; past dates can be selected (no hard block) but deadline notifications won't fire.
- Keyboard opens automatically on the name field; the sheet scrolls so nothing overflows.

### Edit a Goal
Tap the three-dot menu on any goal card → Edit. Pre-fills all existing values including the category.

**Edge conditions:**
- Editing a completed goal (saved ≥ target) is allowed; changing the target amount can re-open the goal.
- Category picker correctly shows the previously selected custom category (not "Other").

### Delete a Goal
Tap the three-dot menu → Delete. Removes the goal from Firestore immediately.

**Edge conditions:**
- No undo / confirmation dialog — deletion is immediate.
- Interstitial ad may show after every 5th tap anywhere on goal cards (threshold-based).

---

## 3. Deposits & Withdrawals

Add or subtract money from any goal from the goal details screen.

- **Deposit** — increases saved amount, triggers milestone and completion notifications if a threshold is crossed.
- **Withdrawal** — decreases saved amount; cannot go below zero (clamped at 0).
- Every transaction is recorded in Firestore under a `transactions` sub-collection with amount, type, note, and date.
- Transactions are listed in the goal details screen in reverse-chronological order.

**Edge conditions:**
- Depositing an amount that pushes saved ≥ target fires the completion notification once (per-goal ID, not repeated).
- Milestone notifications (25 / 50 / 75 / 90 %) fire on the first deposit that crosses each threshold; duplicate firings are prevented by using stable notification IDs derived from the goal ID + milestone offset.
- Withdraw to exactly 0 is allowed and does not delete the goal.

---

## 4. Goal Categories

### Preset Categories
A fixed list of built-in categories (e.g. Travel, Home, Car, Education, Emergency Fund, etc.) each with a unique icon and colour.

### Custom Categories
Users can create their own categories by picking a name, one of 30+ icons, and one of 15 colours. Custom categories are stored per-user in Firestore.

**Edge conditions:**
- Custom categories can be deleted from the category picker; deleting a category does not affect goals already using it (the goal retains its `categoryId`, which will fall back to "Other" display if the category is removed).
- If a custom category is selected in the add-goal sheet and then the picker is closed, the selected category is stored as the full model object so the correct name and icon always render — not "Other".
- The category picker is a `DraggableScrollableSheet` so it works at any screen height.

---

## 5. Goal Filter & Sort

### Status Filter (quick chips)
Three chips on the home screen — **All**, **Pending**, **Completed** — filter the goal list in real time.

### Advanced Filter & Sort (sheet)
Tap the filter icon to open a full sheet with:
- **Category filter** — multi-select; select any combination of categories; empty selection means "show all".
- **Sort options** — Default order · % Progress Low→High / High→Low · Remaining Days Fewest/Most · Amount Low→High / High→Low.

An active filter dot appears on the filter icon when any non-default option is applied. A "Reset" button inside the sheet clears everything.

**Edge conditions:**
- If the active filters produce zero matching goals, a "No goals match this filter" message is shown instead of an empty list.
- Category chips in the filter sheet only show categories that are actually used by at least one goal.
- Filters are held in screen state; navigating away and back resets them (not persisted).

---

## 6. Savings Dashboard

A summary card at the top of the home screen showing:
- Total saved across all goals
- Total target across all goals
- Overall percentage progress bar
- Number of active goals

The card uses a purple gradient and animates the progress bar on load.

**Edge conditions:**
- If all goals are filtered out (filter active), the summary card still shows totals for all goals, not the filtered subset.
- Currency symbol updates live when the user changes their currency selection.

---

## 7. Badges & Achievements

17 badges across four categories, checked automatically whenever the goals list updates.

| Category | Badges |
|---|---|
| Getting started | First Step · Goal Collector · Diversified · All In |
| Progress milestones | Halfway There · On a Roll · Momentum · Multi-Tasker · Almost There |
| Completions | Achiever · Double Win · Hat Trick · Finisher · Grand Slam |
| Special | Early Bird · Dedicated |

- A **celebration overlay** pops up the first time each badge is unlocked (confetti animation + badge card).
- Badges shelf on the home screen shows all badges; locked ones display a padlock icon.
- Tapping the shelf opens the **All Badges** screen with the full list and unlock conditions.

**Edge conditions:**
- Each badge celebration fires only once per device (seen-state stored in Hive `badgesBox`). Reinstalling the app resets seen-state.
- The "Early Bird" badge checks if `goalSavedAmount >= goalAmount` AND `DateTime.now() < deadline`.
- The "Dedicated" badge requires at least 2 goals and all of them at 100%.
- Multiple newly unlocked badges queue and show one after another, not simultaneously.

---

## 8. Savings Streak

Tracks consecutive days the user makes at least one deposit.

- **Current streak** and **longest streak** stored in Firestore on the user document.
- A 🔥 streak pill appears in the greeting row on the home screen when the streak is > 0.
- Tapping the streak pill navigates to the profile screen.

**Edge conditions:**
- Streak is incremented server-side (Firestore) when a deposit is made; a deposit on the same calendar day does not double-increment.
- Missing a day resets the current streak to 1 on the next deposit (not 0).
- Streak reminder notification (configurable time, default 8 PM) reminds users to deposit before midnight.

---

## 9. Currency Selection

Users can pick any currency from a searchable list. The selected currency's symbol and code are used everywhere amounts are displayed.

- Currency is stored in Hive and loaded via `CurrencyCubit` on login.
- A currency pill in the top-right of the home screen shows the active symbol + code.
- Also accessible from Profile → Settings → Currency.

**Edge conditions:**
- Changing currency is cosmetic only — stored amounts in Firestore remain as plain numbers; no conversion is applied.
- Currency picker is a `DraggableScrollableSheet` with a search field.

---

## 10. Theme (Dark / Light Mode)

Toggle between dark and light mode from Profile → Settings → Theme.

- Theme preference stored in Hive via `ThemeCubit`.
- Persists across app restarts.
- The entire design system uses `AppColorsExtension` on `BuildContext` so every screen adapts automatically.

---

## 11. Local Notifications

All notifications are scheduled on-device via `flutter_local_notifications`. No server involvement.

### Scheduled (recurring)
| Notification | Schedule | Default |
|---|---|---|
| Daily Savings Reminder | Every day at user-set time | 9:00 AM, on |
| Weekly Progress Report | Every Sunday at 9:00 AM | on |
| Streak Reminder | Every day at user-set time | 8:00 PM, on |
| Morning Motivation | Every day at 8:00 AM | off |

### Goal Deadline Alerts (auto-scheduled per goal)
- 7 days before deadline
- 3 days before deadline
- 1 day before deadline
- On the deadline day

### Instant (event-triggered)
- **Milestone alerts** — fires immediately when a deposit crosses 25%, 50%, 75%, or 90% of the goal target.
- **Goal completion** — fires immediately when saved amount reaches or exceeds the target.

### Notification Preferences Screen
Accessible via Profile → Settings → Notifications. Sections:
- **Reminders** — daily reminder toggle + time picker; weekly report toggle.
- **Goal Alerts** — deadline alerts toggle; milestone alerts toggle; completion toggle.
- **Motivation & Engagement** — morning motivation toggle; streak reminder toggle + time picker.
- **Permission banner** — shown at the top if system notifications are disabled, with a button to open Settings.

**Edge conditions:**
- Timezone is resolved at startup via `flutter_timezone`; all scheduled times use `tz.local`, so times fire correctly even if the user travels.
- Milestone notifications use stable IDs (`goalId.hashCode % 9000000 + 1000 + offset`) — the same milestone for the same goal always overwrites the same slot, preventing duplicates.
- Deadline notifications are cancelled automatically when a goal is fully funded.
- Disabling a notification type cancels any already-scheduled notifications for that type immediately.
- `AndroidScheduleMode.inexactAllowWhileIdle` is used (not exact) to avoid requiring special Play Store permissions for exact alarms.
- Goals with no deadline date skip deadline scheduling silently.

---

## 12. Ads

- **Banner Ad** — shown at the bottom of the home screen and goal details screen via `BannerAdWidget`.
- **Interstitial Ad** — shown every 5th tap on a goal card (threshold tracked in `AdService`).
- **App Open Ad** — shown when the app comes to the foreground after being in the background, managed by `AppOpenAdManager`.

**Edge conditions:**
- Ads are loaded lazily; if an ad isn't ready it is skipped silently (no crash, no empty placeholder shown for interstitials).
- Banner widget shows nothing if the ad hasn't loaded yet.

---

## 13. Force Update

On app start, the app checks Firestore `app_config/version` for `latest_version` and `is_force_update`.

- If `is_force_update` is `true` and the installed version is older, the user is locked on the `AppUpdateScreen` and cannot proceed until they update.
- If update is available but not forced, the screen is not shown.

**Edge conditions:**
- Version comparison uses semantic versioning; `1.2.0 < 1.10.0` is handled correctly.
- If Firestore is unreachable (no internet), the check fails silently and the user proceeds normally.

---

## 14. Analytics

- **Microsoft Clarity** — session recording and heatmaps. Key events logged: screen views, app opened, goal created/edited/deleted, deposit/withdrawal, badge unlocked, filter applied, category created, currency changed.
- **Session Tracker** — each app open is logged to Firestore (`app_sessions` collection) with user ID, timestamp, date string, platform, and session type (`app_open` or `background_resume`).

**Edge conditions:**
- Analytics calls are fire-and-forget; failures do not affect user-facing functionality.
- Session tracking only fires when a valid `userId` exists in Hive (i.e. user is logged in).
