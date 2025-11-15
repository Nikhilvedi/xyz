# Architecture Diagram

## Complete System Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                         iOS Device                                  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    WorkoutSummaryApp                         │  │
│  │                                                              │  │
│  │  ┌────────────────────────────────────────────────────────┐ │  │
│  │  │                  Presentation Layer                     │ │  │
│  │  │                                                         │ │  │
│  │  │  ┌───────────────────┐    ┌────────────────────────┐  │ │  │
│  │  │  │  ContentView      │    │  WorkoutDayView        │  │ │  │
│  │  │  │  (SwiftUI)        │────│  (SwiftUI Component)   │  │ │  │
│  │  │  │                   │    │                        │  │ │  │
│  │  │  │  - Text Editor    │    │  - Day Label           │  │ │  │
│  │  │  │  - Parse Button   │    │  - Exercise List       │  │ │  │
│  │  │  │  - Summary View   │    │  - Bullet Points       │  │ │  │
│  │  │  └─────────┬─────────┘    └────────────────────────┘  │ │  │
│  │  │            │                                           │ │  │
│  │  └────────────┼───────────────────────────────────────────┘ │  │
│  │               │                                              │  │
│  │  ┌────────────▼───────────────────────────────────────────┐ │  │
│  │  │                  Business Logic Layer                  │ │  │
│  │  │                                                         │ │  │
│  │  │  ┌───────────────────────────────────────────────┐    │ │  │
│  │  │  │         WorkoutViewModel                      │    │ │  │
│  │  │  │         (ObservableObject)                    │    │ │  │
│  │  │  │                                               │    │ │  │
│  │  │  │  @Published var inputText: String            │    │ │  │
│  │  │  │  @Published var workoutDays: [WorkoutDay]    │    │ │  │
│  │  │  │  @Published var isParsed: Bool               │    │ │  │
│  │  │  │                                               │    │ │  │
│  │  │  │  func parseWorkout()                         │    │ │  │
│  │  │  │  func clearAll()                             │    │ │  │
│  │  │  │  func loadSharedText()                       │    │ │  │
│  │  │  └────────────────┬──────────────────────────────┘    │ │  │
│  │  │                   │                                    │ │  │
│  │  │  ┌────────────────▼──────────────────────────────┐    │ │  │
│  │  │  │         WorkoutParser                         │    │ │  │
│  │  │  │                                               │    │ │  │
│  │  │  │  func parse(_ text: String) -> [WorkoutDay]  │    │ │  │
│  │  │  │                                               │    │ │  │
│  │  │  │  - parseDayHeader()                          │    │ │  │
│  │  │  │  - parseExercise()                           │    │ │  │
│  │  │  │  - parseStrengthSets()                       │    │ │  │
│  │  │  │  - parseCardio()                             │    │ │  │
│  │  │  │  - parseBodyweightReps()                     │    │ │  │
│  │  │  └───────────────────────────────────────────────┘    │ │  │
│  │  │                                                         │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │                                                              │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │                    Data Layer                           │ │  │
│  │  │                                                         │ │  │
│  │  │  ┌──────────────────┐      ┌──────────────────┐       │ │  │
│  │  │  │  WorkoutDay      │      │    Exercise      │       │ │  │
│  │  │  │  (Struct)        │      │    (Struct)      │       │ │  │
│  │  │  │                  │      │                  │       │ │  │
│  │  │  │  - id: UUID      │      │  - id: UUID      │       │ │  │
│  │  │  │  - dateLabel     │      │  - rawText       │       │ │  │
│  │  │  │  - exercises[]   │──────│  - sets          │       │ │  │
│  │  │  │                  │      │  - reps          │       │ │  │
│  │  │  │                  │      │  - quantity      │       │ │  │
│  │  │  │                  │      │  - unit          │       │ │  │
│  │  │  │                  │      │  - movement      │       │ │  │
│  │  │  └──────────────────┘      └──────────────────┘       │ │  │
│  │  │                                                         │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │                                                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    ShareExtension                            │  │
│  │                                                              │  │
│  │  ┌────────────────────────────────────────────────────────┐ │  │
│  │  │          ShareViewController                           │ │  │
│  │  │          (UIViewController)                            │ │  │
│  │  │                                                        │ │  │
│  │  │  1. Extract text from NSExtensionItem                │ │  │
│  │  │  2. Handle plain text & RTF                          │ │  │
│  │  │  3. Save to UserDefaults (App Group)                 │ │  │
│  │  │  4. Open main app with URL scheme                    │ │  │
│  │  │                                                        │ │  │
│  │  └────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Shared Storage                            │  │
│  │                                                              │  │
│  │  ┌────────────────────────────────────────────────────────┐ │  │
│  │  │    UserDefaults(suiteName: "group.com...")             │ │  │
│  │  │                                                        │ │  │
│  │  │    Key: "sharedText"                                  │ │  │
│  │  │    Value: String (workout notes)                      │ │  │
│  │  │                                                        │ │  │
│  │  └────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### 1. Normal Usage Flow

```
User Input → ViewModel → Parser → Models → ViewModel → View Update

┌──────┐     ┌──────────┐     ┌────────┐     ┌────────┐
│ User │────▶│ViewModel │────▶│ Parser │────▶│ Models │
└──────┘     └────┬─────┘     └────────┘     └───┬────┘
                  │                                │
                  │◀───────────────────────────────┘
                  │
                  ▼
             ┌────────┐
             │  View  │
             └────────┘
```

### 2. Share Extension Flow

```
Other App → Share Sheet → Extension → Shared Storage → Main App

┌───────────┐
│ Notes App │
└─────┬─────┘
      │ (Share)
      ▼
┌───────────┐
│   Share   │
│   Sheet   │
└─────┬─────┘
      │ (Select Extension)
      ▼
┌──────────────┐
│ShareExtension│
└──────┬───────┘
       │ (Extract Text)
       ▼
┌──────────────┐
│ UserDefaults │
│  (App Group) │
└──────┬───────┘
       │
       │ (Open URL: workoutsummary://share)
       ▼
┌──────────────┐
│   Main App   │
│ (Pre-filled) │
└──────────────┘
```

### 3. Parsing Algorithm Flow

```
Text Input → Split Lines → Identify Day → Parse Exercise → Build Models

┌────────────┐
│ Raw Text   │
└─────┬──────┘
      │
      ▼
┌────────────┐
│Split Lines │
└─────┬──────┘
      │
      ▼
┌────────────┐     Yes    ┌──────────────┐
│  Is Day    │───────────▶│ Create New   │
│  Header?   │            │ WorkoutDay   │
└─────┬──────┘            └──────────────┘
      │ No
      ▼
┌────────────┐     Yes    ┌──────────────┐
│  Matches   │───────────▶│ Parse Sets/  │
│  Pattern?  │            │ Reps/Cardio  │
└─────┬──────┘            └──────┬───────┘
      │ No                       │
      │                          ▼
      │                  ┌──────────────┐
      │                  │ Create       │
      │                  │ Exercise     │
      │                  └──────┬───────┘
      │                         │
      │                         ▼
      │                  ┌──────────────┐
      │                  │ Add to       │
      │                  │ WorkoutDay   │
      │                  └──────────────┘
      │
      ▼
┌────────────┐
│  Ignore    │
│  Line      │
└────────────┘
```

## Pattern Matching Flowchart

```
Exercise Line
      │
      ├──▶ Match "NxN movement"? ──Yes──▶ Strength Sets
      │                            │
      │                           No
      │                            │
      ├──▶ Match "Nk movement"? ──Yes──▶ Cardio Distance
      │                            │
      │                           No
      │                            │
      ├──▶ Match "N min movement"? ─Yes─▶ Cardio Time
      │                            │
      │                           No
      │                            │
      ├──▶ Match "N movement"? ──Yes──▶ Bodyweight Reps
      │                            │
      │                           No
      │                            │
      └──▶ No Match ──────────────────▶ Ignore Line
```

## State Management

```
┌─────────────────────────────────────────┐
│         WorkoutViewModel                │
│                                         │
│  State Variables:                       │
│  ┌─────────────────────────────────┐   │
│  │ @Published inputText: String    │   │
│  │    Initial: ""                  │   │
│  │    Updates: User types text     │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ @Published workoutDays: [Day]   │   │
│  │    Initial: []                  │   │
│  │    Updates: After parsing       │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ @Published isParsed: Bool       │   │
│  │    Initial: false               │   │
│  │    Updates: After parse/clear   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Actions:                               │
│  • parseWorkout() → Updates workoutDays │
│  • clearAll() → Resets all state       │
│  • loadSharedText() → Sets inputText   │
│                                         │
└─────────────────────────────────────────┘
```

## Testing Architecture

```
┌────────────────────────────────────────┐
│      WorkoutParserTests               │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │   Day Detection Tests            │ │
│  │   • Day numbers (Day 1, Day 2)   │ │
│  │   • Weekdays (Mon, Tuesday)      │ │
│  │   • Dates (17/11/25, 2025-11-17) │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │   Exercise Parsing Tests         │ │
│  │   • Strength sets (3x10)         │ │
│  │   • Cardio distance (5k run)     │ │
│  │   • Cardio time (30 min cycle)   │ │
│  │   • Bodyweight (50 push ups)     │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │   Integration Tests              │ │
│  │   • Multiple days                │ │
│  │   • Commentary filtering         │ │
│  │   • Complete examples            │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │   Edge Case Tests                │ │
│  │   • Empty input                  │ │
│  │   • Only headers                 │ │
│  │   • Orphaned exercises           │ │
│  └──────────────────────────────────┘ │
│                                        │
└────────────────────────────────────────┘
```

## Component Dependencies

```
ContentView
    ↓
WorkoutViewModel
    ↓
WorkoutParser
    ↓
Models (WorkoutDay, Exercise)


ShareViewController
    ↓
UserDefaults (App Group)
    ↓
Main App (via URL Scheme)
    ↓
WorkoutViewModel.loadSharedText()
```

## Build Targets

```
┌─────────────────────────────────────────┐
│  WorkoutSummaryApp.xcodeproj            │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  WorkoutSummaryApp (Target)       │ │
│  │  • Main app files                 │ │
│  │  • Bundle ID: com.workoutsummary  │ │
│  │  • Capabilities: App Groups       │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  ShareExtension (Target)          │ │
│  │  • Extension files                │ │
│  │  • Bundle ID: ...app.ShareExt     │ │
│  │  • Capabilities: App Groups       │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  WorkoutSummaryAppTests (Target)  │ │
│  │  • Test files                     │ │
│  │  • Links to main app              │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

## Security & Sandboxing

```
┌──────────────────────────────────────────┐
│          App Sandbox                     │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │    Main App Container              │ │
│  │    • App files                     │ │
│  │    • Private data                  │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │    Extension Container             │ │
│  │    • Extension files               │ │
│  │    • Private data                  │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │    Shared Container                │ │
│  │    (App Group)                     │ │
│  │    • UserDefaults                  │ │
│  │    • Shared data only              │ │
│  └────────────────────────────────────┘ │
│           ↑              ↑               │
│           │              │               │
│     Main App      Extension              │
│                                          │
└──────────────────────────────────────────┘
```

## Memory Management

All structs use value semantics (copy-on-write):
- WorkoutDay: Small struct, cheap to copy
- Exercise: Small struct, cheap to copy
- Arrays: Copy-on-write optimization

ViewModel uses reference semantics (class):
- Single instance shared via @StateObject
- Published properties trigger view updates
- No retain cycles

## Thread Safety

- Main thread: All UI operations
- Parser: Synchronous, runs on main thread (fast enough)
- Share Extension: Background thread for text extraction
- UserDefaults: Thread-safe by default

## Performance Characteristics

- Parse 100 lines: < 10ms
- Update UI: < 16ms (60 FPS)
- Memory: < 1MB for typical workout
- Share Extension: < 100ms startup
