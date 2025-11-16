# HealthKit Integration Guide

## Overview

The app integrates with Apple Health (HealthKit) to automatically sync your workout data, eliminating manual entry for activities tracked by your Apple Watch, iPhone, or other compatible devices.

## Features

### Automatic Workout Import
- One-tap sync from Apple Health
- Fetches last 7 days of workouts
- Converts to parseable text format
- Works with 15+ activity types

### Supported Activities

#### Distance-Based Activities
- 🏃 **Running** - Auto-converts distance to km (e.g., "5.2k run")
- 🚶 **Walking** - Displays as "3.1k walk"
- 🥾 **Hiking** - Shows distance traveled
- 🚴 **Cycling** - Converts to "10.5k cycle"
- 🏊 **Swimming** - Pool or open water distances
- 🚣 **Rowing** - Indoor or outdoor rowing

#### Duration-Based Activities
- 💪 **Strength Training** - "45 min strength training"
- 🔥 **HIIT** - High-intensity interval training
- 🏃 **Cross Training** - General cross-training
- 🧘 **Yoga** - All yoga styles
- 🤸 **Pilates** - Duration-based tracking
- ⬆️ **Elliptical** - Cardio machine workouts
- 🎭 **Dancing** - Various dance styles
- 🥊 **Boxing** - Boxing workouts

#### Other Activities
- Kickboxing, Martial Arts, Stairs, and more
- Generic "workout" for unrecognized types

## Setup Guide

### Initial Setup

1. **Open Settings Tab**
   - Tap the Settings icon (⚙️) in the bottom navigation

2. **Enable HealthKit**
   ```
   HealthKit Integration section
   → Toggle "Enable HealthKit Sync" to ON
   ```

3. **Grant Permission**
   - iOS will prompt: "Workout Summary would like to access your Health data"
   - Tap "Allow"
   - The app requests READ access only

4. **Configure Auto-Sync (Optional)**
   ```
   → Toggle "Auto-sync on app launch" to ON
   ```
   - Workouts automatically load when you open the app
   - Only fills empty input field

### Permission Screen

When you first enable HealthKit:

```
┌─────────────────────────────────────────────┐
│  "Workout Summary" Would Like to            │
│  Access Your Health Data                    │
│                                             │
│  Turn On All                                │
│  ☑️ Workouts                                │
│  ☑️ Active Energy                           │
│  ☑️ Walking + Running Distance              │
│  ☑️ Cycling Distance                        │
│  ☑️ Swimming Distance                       │
│                                             │
│  [Don't Allow]              [Allow]         │
└─────────────────────────────────────────────┘
```

**Important:** You must tap "Allow" or select specific data types to enable sync.

## Using HealthKit Sync

### Manual Sync

1. **Go to Workouts Tab**
   - Main screen with text input

2. **Tap Sync Button**
   ```
   ┌─────────────────────────────────────────────┐
   │  ❤️ Sync from Apple Health                 │
   └─────────────────────────────────────────────┘
   ```

3. **Wait for Sync**
   - Progress indicator shows "Syncing..."
   - Usually takes 1-3 seconds

4. **Review Results**
   - Success: "Successfully synced workouts from the last 7 days!"
   - Workouts appear in text editor
   - Ready to parse

5. **Parse Data**
   - Tap "Parse Summary" button
   - View results with muscle heatmap

### Auto-Sync

With auto-sync enabled:

```
Open App
    ↓
App checks HealthKit permission
    ↓
Fetches last 7 days automatically
    ↓
Fills text editor (if empty)
    ↓
Ready to parse
```

**Note:** Auto-sync only fills the input field if it's empty. It won't overwrite any existing text.

## Sync Output Examples

### Running Workout

**HealthKit Data:**
- Activity: Running
- Distance: 5.2 km
- Date: Nov 15, 2025

**Synced Text:**
```
15/11/25
5.2k run
```

### Multiple Workouts Same Day

**HealthKit Data:**
- Morning: 5k run
- Evening: 30 min strength training

**Synced Text:**
```
15/11/25
5.0k run
30 min strength training
```

### Week of Workouts

**HealthKit Data:**
- Mon: 5k run
- Tue: 45 min strength
- Wed: 10k cycle
- Thu: Rest
- Fri: 3k swim + yoga
- Sat: HIIT
- Sun: Long run

**Synced Text:**
```
17/11/25
12.3k run

16/11/25
30 min HIIT

15/11/25
3.1k swim
60 min yoga

13/11/25
10.2k cycle

12/11/25
45 min strength training

11/11/25
5.0k run
```

## Data Conversion

### Distance Conversion

HealthKit stores distances in meters. The app converts to kilometers:

```
1000 meters  → 1.0k
5234 meters  → 5.2k
10500 meters → 10.5k
```

### Duration Conversion

HealthKit stores durations in seconds. The app converts to minutes:

```
1800 seconds → 30 min
2700 seconds → 45 min
3600 seconds → 60 min
```

### Date Formatting

HealthKit uses full timestamps. The app formats to DD/MM/YY:

```
2025-11-15 08:30:00 → 15/11/25
2025-11-14 18:45:00 → 14/11/25
```

## Activity Type Mapping

### How Activities Are Named

| HealthKit Type | Synced Text Format |
|----------------|-------------------|
| Running | "5.2k run" or "30 min run" |
| Cycling | "10.5k cycle" or "45 min cycle" |
| Swimming | "2.0k swim" or "30 min swim" |
| Walking | "3.1k walk" or "20 min walk" |
| Traditional Strength Training | "45 min strength training" |
| Functional Strength Training | "30 min strength" |
| HIIT | "30 min HIIT" |
| Yoga | "60 min yoga" |
| Pilates | "45 min pilates" |
| Rowing | "5.0k row" or "30 min row" |
| Elliptical | "30 min elliptical" |
| Stairs | "15 min stairs" |
| Cross Training | "45 min cross training" |
| Boxing | "30 min boxing" |
| Kickboxing | "30 min kickboxing" |
| Dancing | "45 min dance" |
| Hiking | "8.2k hike" |
| Martial Arts | "30 min martial arts" |

### Priority: Distance Over Duration

If a workout has both distance and duration:
- Distance is preferred for cardio activities
- Duration is used as fallback

Example:
- 5k run in 30 minutes → Shows as "5.0k run"
- Treadmill run with no distance → Shows as "30 min run"

## Workflow Examples

### Example 1: Apple Watch User

```
Monday Morning:
1. Run 5k with Apple Watch
2. Activity automatically saved to Apple Health

Later that day:
1. Open Workout Summary app
2. If auto-sync enabled: Workouts already loaded
3. If manual: Tap "Sync from Apple Health"
4. See: "15/11/25\n5.0k run"
5. Tap "Parse Summary"
6. View muscle map and stats
```

### Example 2: Multiple Activities

```
Throughout the week:
- Monday: Strength training (Apple Watch)
- Tuesday: 10k cycle ride (Strava → Apple Health)
- Wednesday: Yoga class (manual entry in Health app)
- Friday: 5k run (Apple Watch)

Sunday evening:
1. Open app
2. Tap "Sync from Apple Health"
3. All 4 workouts imported
4. Grouped by date
5. Parse and review weekly progress
```

### Example 3: Mixed Input

```
You have both:
- Cardio tracked in Apple Health
- Strength workouts in notes

Workflow:
1. Sync from Apple Health (gets cardio)
2. Manually add strength notes below
3. Parse everything together
4. Complete weekly summary
```

## Troubleshooting

### Not Syncing?

**Check these:**

1. ✅ HealthKit enabled in Settings tab
2. ✅ Permission granted (iOS Settings → Workout Summary → Health)
3. ✅ Workouts exist in Apple Health
4. ✅ Workouts are within last 7 days
5. ✅ Activity types are supported

### Permission Denied?

If you accidentally denied permission:

1. Open iOS Settings
2. Scroll to "Workout Summary"
3. Tap "Health"
4. Enable data categories you want to sync
5. Return to app and try again

### No Workouts Found?

Possible reasons:
- No workouts in last 7 days
- Workouts not saved to Apple Health
- Third-party apps not syncing to Health
- Activity types not yet supported

### Sync Shows Wrong Data?

HealthKit data depends on:
- Accuracy of source app/device
- GPS signal (for outdoor activities)
- Manual corrections in Health app
- Data from multiple sources

Check Apple Health app to verify data is correct.

## Privacy & Security

### What We Access

✅ **Read-only access to:**
- Workout activity data
- Exercise distances
- Activity durations
- Workout dates

### What We DON'T Access

❌ **No access to:**
- Heart rate data
- Personal health metrics
- Body measurements
- Sleep data
- Nutrition data
- Location data beyond what's in workouts
- Any other Health app data

### Data Storage

- ✅ No workout data stored permanently
- ✅ Only temporary during sync process
- ✅ Converted to text and discarded
- ✅ Settings stored locally only
- ✅ No cloud sync of Health data
- ✅ No third-party sharing

### Permissions

- **Read-Only:** App never writes to HealthKit
- **User Control:** Enable/disable anytime
- **Transparent:** Clear permission explanations
- **Selective:** Grant access to specific data types only

## Settings Management

### Disabling HealthKit

**In App:**
1. Go to Settings tab
2. Toggle "Enable HealthKit Sync" to OFF
3. Sync button disappears from Workouts tab
4. No more automatic syncing

**In iOS Settings:**
1. Open iOS Settings
2. Scroll to "Workout Summary"
3. Tap "Health"
4. Turn off all data categories
5. Or tap "Turn Off All Categories"

### Re-enabling HealthKit

1. Go back to Settings tab
2. Toggle "Enable HealthKit Sync" to ON
3. If previously denied, you'll be directed to iOS Settings
4. Enable permissions there
5. Return to app

## Best Practices

### For Apple Watch Users

✅ **Recommended Setup:**
- Enable HealthKit sync
- Enable auto-sync on launch
- Open app weekly to review
- Let Watch track everything automatically

### For Manual + Health Combo

✅ **Recommended Workflow:**
- Use Health for cardio (tracked automatically)
- Manual entry for strength training details
- Sync Health data first
- Add strength notes below
- Parse together for complete picture

### For Privacy-Conscious Users

✅ **Recommended Approach:**
- Keep HealthKit disabled
- Manual text entry only
- Complete privacy
- No data access by app

## Technical Details

### Sync Window

- **Default:** Last 7 days
- **Rationale:** Matches typical weekly review cycle
- **Cannot be changed:** Fixed to prevent performance issues

### Data Freshness

- **Real-time:** Syncs latest data each time
- **No caching:** Always fetches fresh from HealthKit
- **Instant updates:** New workouts appear immediately

### Performance

- **Fast:** Typically 1-3 seconds
- **Efficient:** Only fetches needed data
- **Lightweight:** Minimal battery impact
- **Background-safe:** No background fetching

### Compatibility

- **iOS 15.0+:** Required for HealthKit features
- **watchOS:** Compatible with all Apple Watch data
- **Third-party apps:** Works with any app that syncs to Health
- **Devices:** iPhone, iPad (with Health app)

## Integration with Other Apps

### Strava

Strava syncs to Apple Health:
1. Enable Health sync in Strava settings
2. Workout Summary can read that data
3. All Strava activities available

### Nike Run Club

Nike Run Club syncs automatically:
1. Workouts appear in Apple Health
2. Sync in Workout Summary
3. Running data imported

### MyFitnessPal, Fitbit, etc.

Most fitness apps support Health integration:
1. Enable in each app's settings
2. Data flows to Apple Health
3. Available in Workout Summary

## Summary

✅ **Easy Setup:** One-time permission, persistent settings
✅ **Automatic Import:** Sync with one tap or automatically
✅ **Wide Support:** 15+ activity types
✅ **Privacy First:** Read-only, no permanent storage
✅ **Flexible:** Manual or auto-sync, your choice
✅ **Integrated:** Works with existing app features

Track workouts your way, with seamless Apple Health integration! 🏃‍♂️💪🚴‍♀️
