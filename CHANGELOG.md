# Changelog

## 1.4.0 (build 5)

### Added
- **Date format setting.** Profile → Date Format lets you pick how dates are
  shown across the app (DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD and three more).
  The choice is saved per user. Dates are still stored as `yyyy-MM-dd`, so the
  setting only affects display.
- **Push announcements.** The app registers a device token on open so product
  announcements can be sent from the admin panel. Messages that arrive while
  the app is open are now drawn by the app itself, which FCM does not do.
- **New app icon** across every Android density and iOS size, with proper
  adaptive-icon support on Android 8+ (foreground, background and masking).

### Fixed
- **Scheduled notifications never fired on Android.** The plugin's required
  broadcast receivers were missing from the manifest, so the daily reminder,
  streak reminder, weekly report, morning motivation and all goal deadline
  alerts were silently dropped. They now fire, and survive a reboot or an
  app update.
- **App hung on the splash screen.** A stray `return` made the version check
  and the navigation that follows it unreachable.
- **Force-update check compared the wrong version.** It read a hardcoded
  constant that had drifted two releases behind the real build; it now reads
  the installed version at runtime.
- **A deleted goal stayed on the home screen** until the next cold start.
- **A deleted goal's reminders stayed scheduled**, so alerts kept arriving for
  goals that no longer existed.
- **Turning off goal deadline alerts left existing alerts queued.**
- **The savings chart showed `$`** on its axis regardless of the currency you
  had chosen, while the tooltip on the same chart showed the right symbol.
- **Goal details: a long status label squeezed the date** until it wrapped one
  character per line.
- **Add Goal overflowed behind the keyboard.** Tall bottom sheets now scroll.
- **Custom category icons broke release builds.** Icons are resolved to const
  values so the icon font can be tree-shaken.

### Changed
- A goal that is finished after its target date no longer shows a "late" chip.
  It just reads as achieved.
- Dates are now shown in one consistent format everywhere.
