# Xcode Project Setup Guide

This guide walks you through creating the Xcode project for the Workout Summary App.

## Step 1: Create New iOS App Project

1. Open Xcode
2. Click "Create a new Xcode project"
3. Select "iOS" → "App"
4. Click "Next"
5. Configure the project:
   - **Product Name**: `WorkoutSummaryApp`
   - **Team**: Select your team (or None for simulator only)
   - **Organization Identifier**: `com.workoutsummary`
   - **Bundle Identifier**: `com.workoutsummary.app`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None
   - **Include Tests**: Yes
6. Click "Next" and choose where to save the project

## Step 2: Add Source Files to Main App

1. Delete the default `ContentView.swift` and `WorkoutSummaryAppApp.swift`
2. Add all Swift files from `WorkoutSummaryApp/WorkoutSummaryApp/`:
   - Drag and drop from Finder, or
   - Right-click the project folder → "Add Files to WorkoutSummaryApp..."
3. Files to add:
   - `WorkoutSummaryApp.swift`
   - `ContentView.swift`
   - `Models.swift`
   - `WorkoutParser.swift`
   - `WorkoutViewModel.swift`

## Step 3: Add Info.plist and Entitlements

1. Replace the default `Info.plist` with the one from the repository
2. Add `WorkoutSummaryApp.entitlements` to the project

## Step 4: Enable App Groups

1. Select the WorkoutSummaryApp target
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "App Groups"
5. Click "+" under App Groups
6. Enter: `group.com.workoutsummary.app`
7. Click "OK"

## Step 5: Create Share Extension Target

1. File → New → Target
2. Select "Share Extension"
3. Click "Next"
4. Configure:
   - **Product Name**: `ShareExtension`
   - **Team**: Same as main app
   - **Language**: Swift
5. Click "Finish"
6. When asked "Activate ShareExtension scheme?", click "Cancel"

## Step 6: Add Share Extension Files

1. Delete the default Share Extension files
2. Add files from `WorkoutSummaryApp/ShareExtension/`:
   - `ShareViewController.swift`
   - `Info.plist`
   - `ShareExtension.entitlements`
3. Make sure they're added to the ShareExtension target (not the main app)

## Step 7: Enable App Groups for Share Extension

1. Select the ShareExtension target
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "App Groups"
5. Check the existing group: `group.com.workoutsummary.app`

## Step 8: Configure URL Scheme

This should already be configured in Info.plist, but verify:

1. Select the WorkoutSummaryApp target
2. Go to "Info" tab
3. Expand "URL Types"
4. Verify there's an entry with:
   - **Identifier**: `workoutsummary`
   - **URL Schemes**: `workoutsummary`
   - **Role**: Editor

## Step 9: Add Test Files

1. Delete the default test file in WorkoutSummaryAppTests
2. Add `WorkoutParserTests.swift` from `WorkoutSummaryApp/WorkoutSummaryAppTests/`
3. Make sure it's added to the WorkoutSummaryAppTests target

## Step 10: Build and Run

1. Select "WorkoutSummaryApp" scheme
2. Choose a simulator or device
3. Press Cmd+R to build and run
4. The app should launch successfully

## Step 11: Run Tests

1. Press Cmd+U to run all tests
2. All tests should pass (green checkmarks)

## Troubleshooting

### Build Errors

- **"No such module 'WorkoutSummaryApp'"**: Make sure all files are added to the correct target
- **"App Groups not configured"**: Verify both targets have the same App Group enabled
- **"URL scheme conflict"**: Make sure the URL scheme is unique

### Share Extension Not Appearing

- **Extension doesn't show in share menu**: 
  - Clean build folder (Shift+Cmd+K)
  - Rebuild and reinstall the app
  - Extension may take a moment to appear in the system
- **Extension crashes**: Check that both targets are signed with the same team

### Testing Issues

- **Tests not found**: Verify test files are in the test target
- **Import errors**: Make sure `@testable import WorkoutSummaryApp` is at the top of test files

## Next Steps

Once the project builds successfully:

1. Run the app on a simulator
2. Paste the example workout text
3. Tap "Parse Summary"
4. Verify the summary displays correctly
5. Test the Share Extension:
   - Open Notes app
   - Type some workout text
   - Select the text
   - Share → ShareExtension
   - Verify the main app opens with the text

## File Structure in Xcode

```
WorkoutSummaryApp (Project)
├── WorkoutSummaryApp (Target)
│   ├── WorkoutSummaryApp.swift
│   ├── ContentView.swift
│   ├── Models.swift
│   ├── WorkoutParser.swift
│   ├── WorkoutViewModel.swift
│   ├── Info.plist
│   ├── WorkoutSummaryApp.entitlements
│   └── Assets.xcassets
├── ShareExtension (Target)
│   ├── ShareViewController.swift
│   ├── Info.plist
│   └── ShareExtension.entitlements
└── WorkoutSummaryAppTests (Target)
    └── WorkoutParserTests.swift
```

## Additional Resources

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [App Extensions Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/)
- [App Groups Documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
