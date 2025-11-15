# Workout Summary App

A simple iOS SwiftUI app that parses workout notes and generates a weekly summary of exercises.

## Features

- ✅ Text input field for pasting workout notes
- ✅ Share Extension support for receiving text from other apps
- ✅ Intelligent parsing of workout data:
  - Day identification (Day 1, weekdays, dates)
  - Strength sets (e.g., "3x10 pull ups")
  - Cardio exercises (e.g., "5k run", "30 min cycle")
  - Bodyweight reps (e.g., "50 push ups", "max pull ups")
- ✅ Weekly summary view grouped by day
- ✅ Clean SwiftUI interface
- ✅ MVVM architecture
- ✅ Comprehensive unit tests

## Project Structure

```
WorkoutSummaryApp/
├── WorkoutSummaryApp/          # Main app
│   ├── WorkoutSummaryApp.swift # App entry point
│   ├── ContentView.swift       # Main UI
│   ├── Models.swift            # Data models
│   ├── WorkoutParser.swift     # Parsing logic
│   ├── WorkoutViewModel.swift  # ViewModel
│   ├── Info.plist             # App configuration
│   └── WorkoutSummaryApp.entitlements
├── ShareExtension/             # Share Extension
│   ├── ShareViewController.swift
│   ├── Info.plist
│   └── ShareExtension.entitlements
└── WorkoutSummaryAppTests/     # Unit tests
    └── WorkoutParserTests.swift
```

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## How to Build

### Option 1: Using Xcode GUI

1. Open Xcode
2. Create a new iOS App project:
   - Product Name: `WorkoutSummaryApp`
   - Interface: SwiftUI
   - Language: Swift
   - Bundle Identifier: `com.workoutsummary.app`
3. Replace the generated files with the files from this repository
4. Add a new Share Extension target:
   - File > New > Target
   - Share Extension
   - Product Name: `ShareExtension`
   - Bundle Identifier: `com.workoutsummary.app.ShareExtension`
5. Copy the Share Extension files to the new target
6. Enable App Groups capability for both targets:
   - Select target > Signing & Capabilities
   - Add "App Groups" capability
   - Add group: `group.com.workoutsummary.app`
7. Build and run on simulator or device

### Option 2: Manual Setup

Since Xcode project files (.xcodeproj) cannot be easily created manually, follow these steps:

1. **Create the project in Xcode:**
   ```bash
   # Open Xcode and create a new iOS App project with SwiftUI
   ```

2. **Copy the source files:**
   ```bash
   cp -r WorkoutSummaryApp/WorkoutSummaryApp/*.swift <YourXcodeProject>/WorkoutSummaryApp/
   cp WorkoutSummaryApp/WorkoutSummaryApp/Info.plist <YourXcodeProject>/WorkoutSummaryApp/
   cp WorkoutSummaryApp/WorkoutSummaryApp/WorkoutSummaryApp.entitlements <YourXcodeProject>/WorkoutSummaryApp/
   ```

3. **Add Share Extension target in Xcode**

4. **Copy Share Extension files:**
   ```bash
   cp -r WorkoutSummaryApp/ShareExtension/*.swift <YourXcodeProject>/ShareExtension/
   cp WorkoutSummaryApp/ShareExtension/Info.plist <YourXcodeProject>/ShareExtension/
   cp WorkoutSummaryApp/ShareExtension/ShareExtension.entitlements <YourXcodeProject>/ShareExtension/
   ```

5. **Add test files:**
   ```bash
   cp WorkoutSummaryApp/WorkoutSummaryAppTests/*.swift <YourXcodeProject>/WorkoutSummaryAppTests/
   ```

## Usage

### Main App

1. Launch the app
2. Paste your workout notes in the text editor
3. Tap "Parse Summary"
4. View your organized workout summary
5. Tap "New Input" to start over

### Share Extension

1. In iOS Notes or any app with text
2. Select text containing workout notes
3. Tap the Share button
4. Select "Share to Workout Summary"
5. The app will open with the text pre-filled

## Example Input

```
Day 1
3x10 pull ups
3x10 dips
5k run

Day 2
4x8 bench press
30 min cycle

Monday
5x5 squats
50 push ups
```

## Parsing Rules

### Day Identification

The parser recognizes these day formats:
- **Day numbers**: `Day 1`, `Day 2`, etc.
- **Weekdays**: `Monday`, `Tue`, `Friday`, etc.
- **Dates**:
  - Slash format: `17/11/25`
  - ISO format: `2025-11-17`
  - Month format: `17 Nov`, `17 November`

### Exercise Patterns

1. **Strength Sets**: `3x10 pull ups`, `4 x 8 bench press`
   - Extracts: sets, reps, movement name

2. **Cardio Distance**: `5k run`, `3 km row`
   - Extracts: quantity, unit, movement name

3. **Cardio Time**: `30 min cycle`
   - Extracts: duration, unit (min), movement name

4. **Bodyweight Reps**: `50 push ups`, `max pull ups`
   - Extracts: reps (or nil for "max"), movement name

### Ignored Content

- Empty lines
- Commentary (e.g., "felt tired today")
- Lines that don't match any pattern

## Testing

The app includes comprehensive unit tests covering:

- ✅ Day detection (all formats)
- ✅ Exercise extraction
- ✅ Set/rep parsing
- ✅ Cardio parsing (distance and time)
- ✅ Bodyweight rep parsing
- ✅ Multiple days and exercises
- ✅ Edge cases (empty input, commentary, etc.)

### Running Tests

In Xcode:
1. Select the WorkoutSummaryAppTests scheme
2. Press Cmd+U to run all tests

Or use xcodebuild:
```bash
xcodebuild test -scheme WorkoutSummaryApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

## Architecture

### MVVM Pattern

- **Models**: `WorkoutDay`, `Exercise` - Define data structures
- **View**: `ContentView`, `WorkoutDayView` - SwiftUI views
- **ViewModel**: `WorkoutViewModel` - Manages state and business logic
- **Parser**: `WorkoutParser` - Separate parsing logic

### Data Flow

1. User inputs text → `WorkoutViewModel.inputText`
2. User taps "Parse" → `WorkoutViewModel.parseWorkout()`
3. `WorkoutParser.parse()` processes text
4. Results stored in `WorkoutViewModel.workoutDays`
5. SwiftUI views automatically update

### Share Extension Flow

1. User shares text from another app
2. `ShareViewController` extracts text
3. Text saved to `UserDefaults` with App Group
4. Main app opened via custom URL scheme
5. App loads text from shared storage
6. Text auto-filled in input field

## Non-Goals

This app intentionally does NOT include:
- ❌ Database or persistence
- ❌ Cloud sync
- ❌ Authentication
- ❌ Direct Notes app integration
- ❌ Charts or graphs
- ❌ History tracking
- ❌ Special permissions

## License

ISC License - See LICENSE file for details

## Author

Nikhil Vedi

## Contributing

Feel free to submit issues and enhancement requests!
