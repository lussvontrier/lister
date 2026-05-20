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
