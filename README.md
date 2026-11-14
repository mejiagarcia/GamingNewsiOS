# Gaming News for iOS

A native iPhone app for keeping up with video game news and reviews. It is the iOS counterpart to [Gaming News for Android](https://github.com/eagskunst/GamingNews).

## Feature comparison

| Feature | iOS | Android |
|:--|:--:|:--:|
| Gaming news from RSS feeds | ✅ | ✅ |
| Platform categories | ✅ | ✅ |
| English and Spanish | ✅ | ✅ |
| Reviews | ✅ | ✅ |
| Search headlines | ✅ | ✅ |
| Save articles | ✅ | ✅ |
| Choose news sources | ✅ | ✅ |
| Open articles in a browser | ✅ | ✅ |
| Share and copy article links | ✅ | ✅ |
| Light/dark appearance and image settings | ✅ | ✅ |
| Firebase Analytics | ✅ | ✅ |
| Firebase Cloud Messaging | ⚙️ | ⚙️ |
| Mute unwanted headlines | ✅ | ✅ |
| Upcoming game releases | ✅ | ✅ |
| Follow games and receive release reminders | — | ✅ |
| Daily news reminder | — | ✅ |
| Extracted reader mode | — | ✅ |

✅ Implemented in the source · ⚙️ Integration present; availability depends on configuration · — Not yet available on iOS

Headline muting on iOS supports case-sensitive or case-insensitive contains, whole-word, and exact-phrase rules; global or news-category scopes; and an opt-in to apply global rules to Reviews. Rules are saved on-device. Matching articles can be revealed temporarily from the feed.

The iOS Releases tab loads and caches IGDB release records, with platform filters, game-name search, pagination, and exact or approximate dates. The feature has been built and verified with IGDB credentials configured in the target build settings. Each local build must provide `GAMING_NEWS_IGDB_CLIENT_ID` and `GAMING_NEWS_IGDB_CLIENT_SECRET`; they are read from the generated app Info.plist and are not committed. Following games for release reminders and the daily news reminder are separate features and are not yet available on iOS.

The Android notification-topic controls are currently hidden. On iOS, notification permission is requested from Settings.

The iOS app is under development. Saved article details are stored on the device; publisher pages require an internet connection.

## Built with

Swift 6, SwiftUI, UIKit, and Firebase · iOS 18.0+ · iPhone
