# Gaming News for iOS

A native iPhone app for keeping up with video game news and reviews. It is the iOS counterpart to [Gaming News for Android](https://github.com/eagskunst/GamingNews).

## iOS design

News and Reviews use a two-column newspaper-style feed, with larger lead headlines and smaller supporting stories. Cards flow into the currently shorter column, so later stories fill vertical gaps instead of leaving empty space. Releases and Saved use condensed mastheads, warm paper surfaces, and outlined cards with offset shadows. Red filter tiles turn gold when selected. Search fields, article actions, Reader Mode, the article-opening sheet, and all Settings pages share the same light and dark design. Settings uses outlined cards, explicit choices, and custom switches. The red header carries page titles, back controls, and screen actions. It slides away when scrolling down and returns when scrolling up or reaching the top, while keeping its safe-area inset stable so hiding it does not shift the feed. The floating, icon-only tab bar shrinks when dragging down and expands when dragging up or reaching the top. Releasing the drag keeps its current size away from the top. The active tab is gold, and each tab keeps its own navigation stack. The app draws its own icons for tabs, navigation, and content actions. System-owned browser, share, and permission interfaces use platform styling. The custom header supports edge-swipe back on pushed screens. Search uses a gold offset shadow and a visible focus outline. The latest navigation, tab bar, and search changes await on-device verification.

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
| Home-feed prompt for gaming-news notifications (no advertising) | ✅ | — |
| Mute unwanted headlines | ✅ | ✅ |
| Upcoming game releases | ✅ | ✅ |
| Follow games and receive release reminders | — | ✅ |
| Daily news reminder | — | ✅ |
| Extracted reader mode with headings, paragraphs, images, captions, lists, and quotes | ✅ | ✅ |

✅ Implemented in the source · ⚙️ Integration present; availability depends on configuration · — Not yet available on iOS

Headline muting on iOS supports case-sensitive or case-insensitive contains, whole-word, and exact-phrase rules; global or news-category scopes; and an opt-in to apply global rules to Reviews. Rules are saved on-device. Matching articles can be revealed temporarily from the feed.

Tapping an article asks once whether to open it in Reader Mode or on the original publisher page, then remembers the choice. Change it or restore the prompt from Settings. Reader Mode fetches and extracts readable page content on-device, respects the Show Images preference, and provides retry, browser fallback, share, and copy-link actions. Extraction uses SwiftSoup and a main-content heuristic; publisher pages that block requests or use unusual markup may not produce readable content.

The iOS Releases tab loads and caches IGDB release records, with platform filters, game-name search, pagination, and exact or approximate dates. The feature has been built and verified with IGDB credentials configured in the target build settings. Each local build must provide `GAMING_NEWS_IGDB_CLIENT_ID` and `GAMING_NEWS_IGDB_CLIENT_SECRET`; they are read from the generated app Info.plist and are not committed. Following games for release reminders and the daily news reminder are separate features and are not yet available on iOS.

On iOS, the News feed shows a dismissible prompt when notification permission is missing, and users can enable it there or open system Settings after denying the prompt. The app presents notifications as gaming-news-only, with no advertising or promotional messages. Firebase Cloud Messaging is present in the app, but actual remote notification delivery and the content sent are externally configured and have not been verified. Android notification-topic controls are currently hidden.

Interactive buttons use a shared hierarchy: primary, secondary, tertiary, selected filters, and destructive actions. Their visual treatment and haptic intensity are centralized; standard screen buttons inherit secondary-level feedback, while prominent actions, filters, and destructive actions opt into their roles. Haptics fire on press and are implemented locally with UIKit feedback generators.

The iOS app is under development. Saved article details are stored on the device; publisher pages require an internet connection.

## TestFlight release

Open the project in Xcode and build for the simulator without configuring signing. For a physical device, use **Signing & Capabilities** to select your Apple development team; Xcode handles the development profile automatically. These personal settings stay local to Xcode. For TestFlight, copy `.env.example` to `.env` and fill in the App Store Connect API key ID, issuer ID, `.p8` key path, and App Store provisioning profile path. The `.env` file is ignored by Git. The release script overrides automatic signing, reads the team ID and provisioning profile UUID from the configured `.mobileprovision` file, then signs and archives manually. Install its matching Apple Distribution certificate in your keychain. Run `./Scripts/upload_testflight.sh` from the repository root to increment the app's `CURRENT_PROJECT_VERSION`, export an IPA, and upload it to TestFlight. After a successful upload, the script creates a commit containing only the build-number change and an annotated tag in the form `v1.0.0-build.2`; other staged and unstaged changes are excluded. Add `--verbose` for detailed Xcode and upload logs. Set `GAMING_NEWS_IGDB_CLIENT_ID` and `GAMING_NEWS_IGDB_CLIENT_SECRET` in `.env` if you want IGDB releases enabled in the uploaded build. The archive and exported IPA are kept under `build/TestFlight/`.

## Built with

Swift 6, SwiftUI, UIKit, and Firebase · iOS 18.0+ · iPhone
