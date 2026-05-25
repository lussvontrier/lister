# Lister

1. Open `Lister.xcodeproj` in Xcode 26.
2. Create `Config.xcconfig`:

```sh
cp Config.xcconfig.example Config.xcconfig
```

3. Add a TMDB v4 Read Access Token:

```xcconfig
TMDB_ACCESS_TOKEN = eyJ...
```

4. UIKit and SwiftUI implementations live in separate branches.

- Switch to the `uikit` branch to build the UIKit version.
- Switch to the `swiftui` branch to build the SwiftUI version.

```sh
git checkout uikit
git checkout swiftui
```

## Planned Improvements

- Further modularize the feature by extracting presentation-agnostic use cases for movie discovery, cast loading, image loading, caching, and retry behavior, so SwiftUI and UIKit can share more orchestration without sharing UI code.
- Load cast independently from the movie list, with per-movie caching and explicit loading/error states. This would let the app show wallpapers quickly and fetch actors only when needed.
- Introduce a small reusable keyboard coordination layer for UIKit screens, so keyboard dismissal, inset updates, and input accessory behavior are handled consistently outside individual view controllers.
- Create a reusable table-view registration and dequeueing abstraction to reduce cell boilerplate while keeping cell configuration type-safe.
- Expand test coverage around repository mapping, error handling, search behavior, statistics calculation, and view-model state transitions for both UI implementations.
- Move user-facing copy, layout metrics, colors, and repeated UI values into typed constants/design tokens, with a clear path toward localization.
- Add skeleton or shimmer states for initial loading, image loading, and cast refreshes to make network latency feel more intentional.
