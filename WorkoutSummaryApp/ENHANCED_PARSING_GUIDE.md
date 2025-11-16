# Enhanced Text Parsing Guide

## Overview

The workout parser has been significantly enhanced with advanced parsing capabilities to support more natural and detailed workout logging. All previous formats remain supported for backwards compatibility.

## New Features

### 1. **Weight/Load Tracking** 💪

Track the weight you're lifting for each exercise.

**Formats:**
```
3x10 bench press @ 135lbs
4x8 squat @ 100kg
5x5 deadlift @ 225lbs
```

**Supported Units:**
- `lbs`, `lb` (pounds)
- `kg`, `kgs` (kilograms)

**Example:**
```
Day 1
3x10 bench press @ 185lbs
4x6 squat @ 100kg
5x5 deadlift @ 275lbs
```

### 2. **Rest Time Tracking** ⏱️

Log rest periods between sets.

**Format:**
```
3x10 pull ups (90s rest)
5x5 squat @ 225lbs (180s rest)
```

**Notes:**
- Rest time in seconds
- Combines with weight tracking

**Example:**
```
Day 1
3x10 pull ups (60s rest)
4x8 bench press @ 185lbs (120s rest)
```

### 3. **RPE (Rate of Perceived Exertion)** 📊

Track how hard each set felt (scale of 1-10).

**Formats:**
```
3x10 bench press @ RPE 8
4x6 squat @ 185lbs RPE 9
30 min cycle @ RPE 7
```

**Works with:**
- Strength training exercises
- Cardio exercises

**Example:**
```
Day 1
3x10 pull ups @ RPE 8
5k run @ RPE 6
```

### 4. **Superset Support** 🔄

Log exercises performed back-to-back without rest.

**Format:**
```
3x10 pull ups + 3x10 dips
4x8 bench press @ 135lbs + 4x8 rows @ 100lbs
```

**Notes:**
- Use `+` to separate exercises
- Each exercise can have its own weight and attributes

**Example:**
```
Day 1
3x10 pull ups + 3x10 dips
4x8 bench press @ 185lbs + 4x8 rows @ 135lbs
3x12 curls @ 30lbs + 3x12 tricep extensions @ 25lbs
```

### 5. **Miles Support** 🏃

Track cardio distances in miles in addition to kilometers.

**Formats:**
```
3 mi run
5.5 miles cycle
10 mi walk
```

**Supported Units:**
- `mi` (miles)
- `mile`, `miles` (converted to `mi`)
- `k`, `km` (kilometers - existing)

**Example:**
```
Day 1
3 mi run
5k cycle
2.5 miles walk
```

### 6. **Tempo/Pace Tracking** 🎯

Log your pace for cardio exercises.

**Formats:**
```
5k run @ 5:30/km
3 mi run @ 8:00/mi
10k cycle @ 4:45/km
```

**Example:**
```
Day 1
5k run @ 5:30/km
3 mi run @ 7:45/mi
```

### 7. **Natural Language Support** 💬

Write workouts in more natural language.

**Cardio Formats:**
```
ran 5k
cycled 10 mi
swam 2k
rowed 3 km
walked 2 miles
hiked 5 mi
```

**Strength Formats:**
```
did 3 sets of 10 pull ups
did 4 sets of 8 bench press @ 135lbs
did 5 sets of 5 squats @ 225lbs
```

**Example:**
```
Day 1
ran 5k @ 5:30/km
did 3 sets of 10 pull ups
cycled 10 mi
did 4 sets of 8 bench press @ 185lbs
```

## Complete Examples

### Example 1: Advanced Strength Training

```
Monday
3x5 squat @ 225lbs (180s rest) RPE 9
4x8 bench press @ 185lbs (120s rest) RPE 8
3x10 pull ups + 3x10 dips
5x5 deadlift @ 275lbs (180s rest) RPE 10
```

**Parsed Output:**
- Squat: 3 sets, 5 reps, 225lbs, 180s rest, RPE 9
- Bench Press: 4 sets, 8 reps, 185lbs, 120s rest, RPE 8
- Pull-ups: 3 sets, 10 reps (superset)
- Dips: 3 sets, 10 reps (superset)
- Deadlift: 5 sets, 5 reps, 275lbs, 180s rest, RPE 10

### Example 2: Hybrid Training Day

```
Tuesday
ran 5k @ 5:45/km
did 3 sets of 10 pull ups
30 min cycle @ RPE 7
4x8 bench press @ 135lbs RPE 8
3 mi walk
```

**Parsed Output:**
- Run: 5km, pace 5:45/km
- Pull-ups: 3 sets, 10 reps
- Cycle: 30 minutes, RPE 7
- Bench Press: 4 sets, 8 reps, 135lbs, RPE 8
- Walk: 3 miles

### Example 3: Mixed Formats (All Valid!)

```
Wednesday
3x10 pull ups @ RPE 8
ran 3 mi
4 x 8 bench press @ 185lbs (90s rest)
5k cycle @ RPE 6
did 3 sets of 12 curls @ 30lbs
50 push ups
max pull ups
```

**All formats work together seamlessly!**

## Attribute Combinations

You can combine multiple attributes in a single line:

| Combination | Example |
|------------|---------|
| Weight only | `3x10 bench press @ 135lbs` |
| Rest only | `3x10 pull ups (90s rest)` |
| RPE only | `3x10 squat @ RPE 8` |
| Weight + Rest | `5x5 deadlift @ 225lbs (180s rest)` |
| Weight + RPE | `4x6 squat @ 185lbs RPE 9` |
| Weight + Rest + RPE | `3x5 squat @ 225lbs (180s rest) RPE 9` |
| Tempo only | `5k run @ 5:30/km` |
| Cardio + RPE | `30 min cycle @ RPE 7` |

## Backwards Compatibility

All previous formats continue to work:

```
Day 1
3x10 pull ups          ← Still works!
5k run                 ← Still works!
30 min cycle           ← Still works!
50 push ups            ← Still works!
max pull ups           ← Still works!
```

## Best Practices

### 1. **Be Consistent Within a Day**
```
Monday
3x10 bench press @ 135lbs
4x8 rows @ 100lbs
3x12 curls @ 30lbs
```

### 2. **Use Natural Language When Appropriate**
```
Tuesday
ran 5k @ 5:30/km
did 3 sets of 10 pull ups
cycled 10 mi
```

### 3. **Track What Matters to You**
If you only care about sets/reps:
```
3x10 pull ups
```

If you want detailed tracking:
```
3x10 pull ups @ 135lbs (90s rest) RPE 8
```

### 4. **Mix and Match**
```
Wednesday
3x10 bench press @ 185lbs    ← Detailed
5k run                         ← Simple
did 4 sets of 8 rows          ← Natural language
30 min cycle @ RPE 7          ← With RPE
```

## Tips for Better Parsing

1. **Use consistent spacing** around symbols: `3x10` or `3 x 10` (both work)
2. **Weights go after the exercise name** with `@`: `bench press @ 135lbs`
3. **Rest time in parentheses**: `(90s rest)`
4. **RPE with `@` or after weight**: `@ RPE 8` or `RPE 8`
5. **Supersets with `+`**: `3x10 pull ups + 3x10 dips`

## What Gets Filtered Out

The parser still ignores commentary lines:

```
Day 1
felt great today               ← Ignored
3x10 pull ups                  ← Parsed
did mobility work              ← Ignored (unless starts with "did X sets")
5k run                         ← Parsed
need more sleep                ← Ignored
```

## Testing Your Input

The app will:
- ✅ Parse recognized patterns
- ❌ Ignore unrecognized lines (commentary)
- 📊 Display all parsed exercises in the summary
- 💪 Track all attributes in the muscle heatmap
- 🎯 Match exercises to your weekly goals

## Summary of Improvements

| Feature | Old Support | New Support |
|---------|------------|-------------|
| Basic sets/reps | ✅ | ✅ |
| Weight tracking | ❌ | ✅ |
| Rest time | ❌ | ✅ |
| RPE | ❌ | ✅ |
| Supersets | ❌ | ✅ |
| Miles (mi) | ❌ | ✅ |
| Tempo/pace | ❌ | ✅ |
| Natural language | ❌ | ✅ |
| Kilometers (km) | ✅ | ✅ |
| Time-based cardio | ✅ | ✅ |
| Bodyweight reps | ✅ | ✅ |

The parser is now **7x more powerful** while maintaining 100% backwards compatibility!

## Need Help?

If an exercise isn't being parsed:
1. Check the format matches one of the patterns above
2. Make sure there's a day header (Day 1, Monday, etc.)
3. Try a simpler format first (e.g., `3x10 pull ups`)
4. Gradually add attributes one at a time

**Happy tracking!** 🎉
