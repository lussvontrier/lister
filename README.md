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

- Extract presentation-agnostic use cases for movie discovery, cast loading, image loading, caching, retry behavior, and statistics, so SwiftUI and UIKit can share more orchestration without sharing UI code.
- Load cast independently from the movie list, with per-movie caching and explicit loading/error states. This would let the app show wallpapers quickly and fetch actors only when needed.
- Expand test coverage around repository mapping, error handling, search behavior, statistics calculation, and view-model state transitions for both UI implementations.
- Polish list transitions and filtering animations. UIKit currently uses diffable data sources with non-animated snapshots; with more time, the interaction could be tuned to visually match the SwiftUI implementation.
- Introduce a reusable keyboard coordination layer for UIKit screens, so keyboard dismissal, inset updates, and input accessory behavior are handled consistently outside individual view controllers.
- Create a reusable table-view registration and dequeueing abstraction to reduce cell boilerplate while keeping cell configuration type-safe.
- Move user-facing copy into localized resources and organize layout metrics, colors, and repeated UI values into typed constants or design tokens.
- Add skeleton or shimmer states for initial loading, image loading, and cast refreshes to make network latency feel more intentional.
- Add SwiftLint and formatting rules to keep style consistent across branches and reduce review noise.
- Integrate project and resource generation tools such as SwiftGen, Tuist, or XcodeGen to make assets, strings, configuration, and project structure easier to maintain.
