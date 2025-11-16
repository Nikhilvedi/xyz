# Weekly Goals Feature - Visual Guide

## Overview

The weekly goals feature allows you to set exercise targets and automatically track them as you log workouts through the notes input page.

## Two-Tab Interface

```
┌─────────────────────────────────────────────┐
│                                             │
│  [★ Workouts ★]      [  Goals  ]           │ ← Bottom Tabs
│                                             │
└─────────────────────────────────────────────┘
```

## Workouts Tab - With Goals Progress Widget

```
┌─────────────────────────────────────────────┐
│  ☰  Workout Summary                    [⊕] │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ 📊 Weekly Goals            2/3      │   │ ← Progress Summary
│  │                                     │   │
│  │ 💪      🏃      🤸      💪      🏃 │   │ ← Mini Goal Cards
│  │ pull    run    push    dips   cycle│   │
│  │  ups           ups                  │   │
│  │ 2/3     1/2    4/4✓    0/3    1/3  │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Paste your workout notes below             │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ Day 1                               │   │
│  │ 3x10 pull ups                      │   │
│  │ 3x10 dips                          │   │
│  │ 5k run                             │   │
│  │                                     │   │
│  │ Day 2                               │   │
│  │ 4x8 bench press                    │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │        Parse Summary                │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

## Goals Tab - Empty State

```
┌─────────────────────────────────────────────┐
│  Weekly Goals                          [+] │
├─────────────────────────────────────────────┤
│                                             │
│                    🎯                       │
│                                             │
│              No Goals Yet                   │
│                                             │
│   Set weekly workout goals to track         │
│         your progress                       │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │    Add Your First Goal              │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

## Goals Tab - With Goals

```
┌─────────────────────────────────────────────┐
│  Weekly Goals                          [+] │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ 💪  pull ups                    🗑️  │   │
│  │     30 total reps • 3x per week    │   │
│  │                                     │   │
│  │     2 / 3 completed                 │   │
│  │     ████████████░░░░░░░░   67%    │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ 🏃  run                         🗑️  │   │
│  │     5km • 2x per week              │   │
│  │                                     │   │
│  │     2 / 2 completed             ✓  │   │
│  │     ████████████████████  100% │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ 🤸  push ups                    🗑️  │   │
│  │     50 reps • 4x per week          │   │
│  │                                     │   │
│  │     1 / 4 completed                 │   │
│  │     █████░░░░░░░░░░░░░░░   25%    │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

## Add Goal Screen

```
┌─────────────────────────────────────────────┐
│  [Cancel]        Add Goal           [Add]  │
├─────────────────────────────────────────────┤
│                                             │
│  GOAL DETAILS                               │
│  ┌─────────────────────────────────────┐   │
│  │ Exercise name (e.g., pull ups, run)│   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Type                                       │
│  💪 Strength              ▾                │
│                                             │
│  TARGET                                     │
│  ┌──────────────────┐                      │
│  │ 30               │  total reps          │
│  └──────────────────┘  (sets × reps)       │
│                                             │
│  Times per week               3            │
│                                             │
│  EXAMPLES                                   │
│  Example: 30 reps (like 3x10) of pull ups, │
│  3 times per week                           │
│                                             │
└─────────────────────────────────────────────┘
```

## Goal Types

### 💪 Strength
```
Target: Total reps (sets × reps)
Example: 30 reps = 3x10 pull ups
Frequency: 3x per week

Matches workouts like:
- "3x10 pull ups" (30 reps) ✓
- "5x5 pull ups" (25 reps) ✗ (below target)
- "4x10 pull ups" (40 reps) ✓
```

### 🏃 Cardio (Distance)
```
Target: Distance in km
Example: 5km run
Frequency: 2x per week

Matches workouts like:
- "5k run" ✓
- "3k run" ✗ (below target)
- "10k run" ✓
```

### ⏱️ Cardio (Time)
```
Target: Time in minutes
Example: 30 min cycle
Frequency: 3x per week

Matches workouts like:
- "30 min cycle" ✓
- "20 min cycle" ✗ (below target)
- "45 min cycle" ✓
```

### 🤸 Bodyweight
```
Target: Single-set reps
Example: 50 push ups
Frequency: 4x per week

Matches workouts like:
- "50 push ups" ✓
- "30 push ups" ✗ (below target)
- "75 push ups" ✓
```

## How Goals Are Tracked

### Step 1: Set Your Goals
```
Goals Tab:
- "pull ups" - Strength - 30 reps - 3x/week
- "run" - Cardio (Distance) - 5km - 2x/week
```

### Step 2: Log Your Workouts
```
Workouts Tab - Input:

Day 1
3x10 pull ups    ← Matches "pull ups" goal ✓ (30 reps)
5k run           ← Matches "run" goal ✓ (5km)

Day 2
3x10 pull ups    ← Matches "pull ups" goal ✓ (30 reps)
```

### Step 3: Automatic Tracking
```
After parsing, goals update:

Pull ups: 2/3 completed (67%)  [Day 1 ✓, Day 2 ✓]
Run:      1/2 completed (50%)  [Day 1 ✓]
```

### Step 4: See Progress Everywhere
```
Input Screen Widget:
💪 pull ups: 2/3
🏃 run: 1/2

Goals Tab:
Full progress bars and details
```

## Goal Matching Logic

### Exercise Name Matching
```
Goal: "pull ups"

Matches:
✓ "3x10 pull ups"
✓ "pull ups"
✓ "weighted pull ups"
✗ "push ups" (different exercise)
✗ "3x10 dips" (different exercise)
```

### Type Validation
```
Goal: "run" - Cardio (Distance)

Matches:
✓ "5k run" (distance + correct name)
✗ "30 min run" (time, not distance)
✗ "3x10 squats" (strength, not cardio)
```

### Target Validation
```
Goal: "pull ups" - 30 reps

Matches:
✓ "3x10 pull ups" (30 reps - meets target)
✓ "4x10 pull ups" (40 reps - exceeds target)
✗ "2x10 pull ups" (20 reps - below target)
```

## Progress Indicators

### Progress Bar Colors
```
Not Started:  ░░░░░░░░░░░░░░░░░░░░  (gray)
In Progress:  ████████░░░░░░░░░░░░  (blue)
Completed:    ████████████████████  (green) ✓
```

### Completion Status
```
0/3 completed  → Gray bar, no checkmark
1/3 completed  → Blue bar, no checkmark (33%)
2/3 completed  → Blue bar, no checkmark (67%)
3/3 completed  → Green bar, green checkmark ✓
```

## Persistence

Goals are saved automatically and persist:
- ✓ Across app restarts
- ✓ When switching tabs
- ✓ When parsing new workouts
- ✓ When adding/deleting goals

## Benefits

1. **Visual Tracking**: See goal progress at a glance
2. **Automatic Updates**: No manual checking required
3. **Motivation**: Clear targets to hit each week
4. **Flexibility**: Support for all exercise types
5. **Persistence**: Goals saved between sessions

## Example Weekly Flow

### Monday
```
Input: "Day 1: 3x10 pull ups, 5k run"
Goals Update:
- Pull ups: 1/3 ✓
- Run: 1/2 ✓
```

### Wednesday
```
Input: "Day 2: 3x10 pull ups, 50 push ups"
Goals Update:
- Pull ups: 2/3 ✓
- Run: 1/2
- Push ups: 1/4 ✓
```

### Friday
```
Input: "Day 3: 3x10 pull ups, 5k run"
Goals Update:
- Pull ups: 3/3 ✓✓✓ COMPLETED!
- Run: 2/2 ✓✓ COMPLETED!
- Push ups: 1/4 ✓
```

### Weekend
Check Goals Tab to see:
- 2 goals completed (pull ups, run) 🎉
- 1 goal in progress (push ups)
- Plan next week's workouts accordingly

## Tips

1. **Set Realistic Goals**: Start with achievable targets
2. **Use Specific Names**: "pull ups" is better than just "ups"
3. **Match Your Routine**: Set frequency based on your schedule
4. **Check Progress Often**: Use the mini widget on input screen
5. **Adjust as Needed**: Delete and recreate goals if targets change
