# SocialPublisher MVP

Native macOS SwiftUI MVP for local-first social media content planning, media storage, date-based scheduling, and mock publishing.

## Run

Open `SocialPublisher.xcodeproj` in Xcode and run the `SocialPublisher` scheme.

CLI build:

```bash
xcodebuild -project SocialPublisher.xcodeproj -scheme SocialPublisher -configuration Debug -derivedDataPath DerivedData build
```

## Project Structure

```text
SocialPublisher/
├── SocialPublisher.xcodeproj/
├── SocialPublisher/
│   ├── App/
│   │   └── SocialPublisherApp.swift
│   ├── Models/
│   │   ├── MediaAsset.swift
│   │   ├── PostItem.swift
│   │   ├── PostStatus.swift
│   │   ├── PublishLog.swift
│   │   ├── SocialAccount.swift
│   │   └── SocialPlatform.swift
│   ├── Views/
│   │   ├── AccountsView.swift
│   │   ├── CalendarView.swift
│   │   ├── DashboardView.swift
│   │   ├── MediaLibraryView.swift
│   │   ├── OnboardingView.swift
│   │   ├── PostEditorView.swift
│   │   ├── PostListView.swift
│   │   ├── PublishLogView.swift
│   │   └── SettingsView.swift
│   ├── ViewModels/
│   │   ├── AccountsViewModel.swift
│   │   ├── DashboardViewModel.swift
│   │   ├── MediaLibraryViewModel.swift
│   │   └── PostEditorViewModel.swift
│   ├── Services/
│   │   ├── MediaStorageService.swift
│   │   ├── SampleDataSeeder.swift
│   │   └── SchedulerService.swift
│   ├── Connectors/
│   │   ├── ConnectorFactory.swift
│   │   ├── PlatformConnectors.swift
│   │   └── SocialPlatformConnector.swift
│   ├── Utilities/
│   │   ├── DateFormatters.swift
│   │   └── MediaThumbnailView.swift
│   └── SocialPublisher.entitlements
└── README.md
```

## Media Library

Imported media is copied into the app's Application Support folder:

```text
~/Library/Application Support/SocialPublisher/MediaLibrary/
```

When the app runs with App Sandbox enabled, macOS may resolve this inside the app container:

```text
~/Library/Containers/com.local.SocialPublisher/Data/Library/Application Support/SocialPublisher/MediaLibrary/
```

The exact folder is shown in Settings and can be opened in Finder from the app.

## API Integration Points

Official social API clients should replace the mock connector classes in:

```text
SocialPublisher/Connectors/
```

Start with `SocialPlatformConnector.swift`, then swap the placeholder classes in `PlatformConnectors.swift` and keep `ConnectorFactory.swift` as the platform router. No scraping or browser automation is used or expected.
