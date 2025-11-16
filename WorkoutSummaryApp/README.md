# Workout Summary App

A comprehensive iOS SwiftUI app that parses workout notes and generates weekly summaries with muscle group analysis, visual heatmap, goal tracking, smart notifications, and HealthKit integration.

## Features

- ✅ Text input field for pasting workout notes
- ✅ Share Extension support for receiving text from other apps
- ✅ **NEW: HealthKit Integration**
  - Automatically sync workouts from Apple Health
  - Support for running, cycling, swimming, strength training, HIIT, yoga, and more
  - One-tap sync button
  - Optional auto-sync on app launch
  - Converts HealthKit workouts to text format
- ✅ Intelligent parsing of workout data:
  - Day identification (Day 1, weekdays, dates)
  - Strength sets (e.g., "3x10 pull ups")
  - Cardio exercises (e.g., "5k run", "30 min cycle")
  - Bodyweight reps (e.g., "50 push ups", "max pull ups")
- ✅ **Weekly summary with muscle group analysis**
  - Visual body heatmap showing which muscles were targeted
  - Color-coded intensity levels (not targeted, light, moderate, heavy)
  - Detailed muscle group breakdown
  - Exercise statistics by day
- ✅ **Weekly Goal Tracking**
  - Set weekly exercise goals (strength, cardio distance, cardio time, bodyweight)
  - Track completion automatically as you log workouts
  - Visual progress indicators and completion status
  - Goals persist across app sessions
  - See goals progress on the input screen
- ✅ **Smart Notifications**
  - Weekly summary notifications (customizable day and time)
  - Goal completion alerts
  - Persistent settings
  - Full notification management in Settings tab
- ✅ Three-tab interface:
  - Workouts: Input and view workout summaries with HealthKit sync
  - Goals: Manage weekly targets and track progress
  - Settings: Configure HealthKit, notifications, and preferences
- ✅ Clean SwiftUI interface
- ✅ MVVM architecture
- ✅ Comprehensive unit tests

## Project Structure

```
WorkoutSummaryApp/
├── WorkoutSummaryApp/          # Main app
│   ├── WorkoutSummaryApp.swift # App entry point
│   ├── ContentView.swift       # Main UI with HealthKit sync
│   ├── Models.swift            # Data models
│   ├── WorkoutParser.swift     # Parsing logic
│   ├── WorkoutViewModel.swift  # ViewModel
│   ├── MuscleGroup.swift       # Muscle mapping logic
│   ├── BodyHeatmapView.swift   # Visual body heatmap
│   ├── WeeklySummaryView.swift # Enhanced summary view
│   ├── WorkoutGoal.swift       # Goal models and matching
│   ├── GoalsView.swift         # Goal management UI
│   ├── NotificationManager.swift # Notification handling
│   ├── HealthKitManager.swift  # NEW: HealthKit integration
│   ├── SettingsView.swift      # Settings UI with HealthKit config
│   ├── Info.plist             # App configuration with HealthKit permissions
│   └── WorkoutSummaryApp.entitlements # Includes HealthKit capability
├── ShareExtension/             # Share Extension
│   ├── ShareViewController.swift
│   ├── Info.plist
│   └── ShareExtension.entitlements
└── WorkoutSummaryAppTests/     # Unit tests
    ├── WorkoutParserTests.swift
    ├── MuscleMapperTests.swift
    ├── WorkoutGoalTests.swift
    └── NotificationManagerTests.swift # NEW: Notification tests
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

### Main App - Workouts Tab

1. Launch the app (starts on Workouts tab)
2. See your weekly goals progress at the top (if any goals are set)
3. Paste your workout notes in the text editor OR sync from Apple Health
4. Tap "Parse Summary"
5. View your organized workout summary with three tabs:
   - **Daily**: See exercises grouped by day
   - **Muscle Map**: Visual body heatmap showing muscles worked
   - **Stats**: Detailed statistics and breakdowns
6. Tap "New Input" to start over

### HealthKit Integration - Automatic Workout Sync

The app integrates with Apple Health to automatically import your workouts:

1. **Enable HealthKit**:
   - Go to Settings tab
   - Toggle "Enable HealthKit Sync"
   - Grant permission when prompted
   - The app will read workout data from Apple Health

2. **Sync Workouts**:
   - On the Workouts tab, tap "Sync from Apple Health" button
   - App fetches workouts from the last 7 days
   - Workouts are automatically converted to text format
   - Data is added to the input field for parsing

3. **Auto-Sync on Launch**:
   - In Settings, enable "Auto-sync on app launch"
   - Workouts automatically load when you open the app
   - Only fills empty input field (won't overwrite existing text)

4. **Supported Activities**:
   - 🏃 Running, Walking, Hiking (with distance)
   - 🚴 Cycling (with distance)
   - 🏊 Swimming (with distance)
   - 💪 Strength Training (duration-based)
   - 🔥 HIIT, Cross Training
   - 🧘 Yoga, Pilates
   - 🚣 Rowing (with distance)
   - ⬆️ Elliptical, Stairs, and more

5. **Example Sync Output**:
   ```
   15/11/25
   5.2k run
   30 min strength training
   
   14/11/25
   10.1k cycle
   45 min yoga
   ```

### Goals Tab - Track Your Weekly Targets

The Goals tab lets you set and track weekly exercise targets:

1. **Adding a Goal**:
   - Tap the Goals tab at the bottom
   - Tap the "+" button to add a goal
   - Enter exercise name (e.g., "pull ups", "run", "cycle")
   - Choose goal type:
     - 💪 **Strength**: Track sets × reps (e.g., 30 total reps = 3x10)
     - 🏃 **Cardio (Distance)**: Track distance in km (e.g., 5km run)
     - ⏱️ **Cardio (Time)**: Track time in minutes (e.g., 30 min cycle)
     - 🤸 **Bodyweight**: Track single-set reps (e.g., 50 push ups)
   - Set target value and weekly frequency
   - Tap "Add"

2. **Tracking Progress**:
   - Goals automatically track when you parse matching workouts
   - Progress bars show completion status
   - Green checkmark appears when goal is completed
   - View progress summary on input screen

3. **Example Goals**:
   - "pull ups" - Strength - 30 reps - 3x per week
   - "run" - Cardio (Distance) - 5km - 2x per week
   - "cycle" - Cardio (Time) - 30 min - 3x per week
   - "push ups" - Bodyweight - 50 reps - 4x per week

### Settings Tab - Configure HealthKit, Notifications & Preferences

The Settings tab provides comprehensive app configuration:

1. **HealthKit Integration**:
   - Toggle "Enable HealthKit Sync" to connect with Apple Health
   - Enable "Auto-sync on app launch" for automatic imports
   - View supported activities list
   - Manage HealthKit permissions

2. **Weekly Summary Notifications**:
   - Toggle to enable/disable notifications
   - Select day of week (e.g., Sunday)
   - Choose time (e.g., 8:00 PM)
   - Receive weekly workout summaries automatically

3. **Automatic Notifications**:
   - **Weekly Summary**: Get a notification at your chosen time with workout and goal insights
   - **Goal Completion**: Instant notification when you complete a weekly goal
   - **Customizable Schedule**: Choose the best time for your weekly review

4. **Permission Management**:
   - First-time users will be prompted for HealthKit and notification permissions
   - Settings can be adjusted in iOS Settings if needed

### Muscle Heatmap Feature

The muscle map view provides:
- **Visual body representation** with color-coded muscle groups
- **Heatmap colors**:
  - Gray: Not targeted
  - Yellow: Light intensity
  - Orange: Moderate intensity
  - Red: Heavy intensity
- **Detailed breakdown** showing which muscle groups were worked
- **Smart exercise mapping** - automatically identifies muscles from exercise names

Supported muscle groups:
- Chest, Shoulders, Biceps, Triceps, Forearms
- Abs, Obliques, Upper Back, Lower Back, Lats
- Quads, Hamstrings, Glutes, Calves
- Cardio tracking

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
