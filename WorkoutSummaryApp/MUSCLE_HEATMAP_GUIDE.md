# Muscle Heatmap Feature - Visual Guide

## Overview

The new muscle heatmap feature provides a visual representation of which muscle groups were targeted during the week's workouts, with color-coded intensity levels.

## Three-Tab Interface

```
┌─────────────────────────────────────────────┐
│  ☰  Workout Summary                    [⊕] │
├─────────────────────────────────────────────┤
│                                             │
│  [  Daily  ] [ Muscle Map ] [  Stats  ]    │ ← Tab Selector
│                                             │
└─────────────────────────────────────────────┘
```

## Tab 1: Daily View (Original)

```
┌─────────────────────────────────────────────┐
│  [★ Daily ★] [ Muscle Map ] [  Stats  ]    │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ Day 1                               │   │
│  │  • 3x10 pull ups                   │   │
│  │  • 3x10 dips                       │   │
│  │  • 5k run                          │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ Day 2                               │   │
│  │  • 4x8 bench press                 │   │
│  │  • 30 min cycle                    │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         New Input                   │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Tab 2: Muscle Map (NEW!)

```
┌─────────────────────────────────────────────┐
│  [  Daily  ] [★Muscle Map★] [  Stats  ]    │
├─────────────────────────────────────────────┤
│                                             │
│        Week Overview                        │
│        2 workout days                       │
│        5 total exercises                    │
│                                             │
│   Muscle Groups Targeted                    │
│                                             │
│         ╭───╮                               │
│         │   │  ← Head                       │
│         ╰───╯                               │
│                                             │
│    ╭─🟠─╮   ╭─🟠─╮  ← Shoulders (Moderate) │
│    │     ╭───╮     │                        │
│    │     │🔴│     │  ← Chest (Heavy)       │
│    │     ╰───╯     │                        │
│    │               │                        │
│ 🟠 │   ╭─────╮   │ 🟠  ← Biceps/Triceps   │
│    │   │ 🟡  │   │      (Light/Moderate)  │
│    │   │     │   │                         │
│    │   ╰─────╯   │                         │
│    ╰───────────────╯                        │
│         │     │                             │
│      ╭──┴─╮ ╭─┴──╮                         │
│      │ 🟡 │ │ 🟡 │  ← Legs (Light)        │
│      │    │ │    │                         │
│      ╰────╯ ╰────╯                         │
│                                             │
│  Legend:                                    │
│  ⬜ Not Targeted  🟡 Light                 │
│  🟠 Moderate      🔴 Heavy                 │
│                                             │
│  Detailed Breakdown                         │
│  ┌─────────────────────────────────────┐   │
│  │ 🔴 Chest          Heavy             │   │
│  │ 🟠 Shoulders      Moderate          │   │
│  │ 🟠 Triceps        Moderate          │   │
│  │ 🟠 Lats           Moderate          │   │
│  │ 🟡 Biceps         Light             │   │
│  │ 🟡 Upper Back     Light             │   │
│  │ ⬜ Abs            Not Targeted       │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         New Input                   │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Tab 3: Statistics (NEW!)

```
┌─────────────────────────────────────────────┐
│  [  Daily  ] [ Muscle Map ] [★ Stats ★]    │
├─────────────────────────────────────────────┤
│                                             │
│  Overall Statistics                         │
│  ┌─────────────────────────────────────┐   │
│  │ Total Workout Days          2       │   │
│  │ Total Exercises             5       │   │
│  │ Strength Exercises          4       │   │
│  │ Cardio Sessions             1       │   │
│  │ Total Volume           120 reps     │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Daily Breakdown                            │
│  ┌─────────────────────────────────────┐   │
│  │ Day 1                               │   │
│  │ Exercises: 3    Muscles: 8         │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ Day 2                               │   │
│  │ Exercises: 2    Muscles: 5         │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         New Input                   │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## How the Heatmap Works

### Exercise-to-Muscle Mapping

When you enter exercises, they're automatically mapped to muscle groups:

```
Input: "3x10 bench press"
  ↓
Detected: bench press
  ↓
Muscles: Chest (primary)
         Triceps (secondary)
         Shoulders (secondary)
```

### Intensity Calculation

The heatmap calculates intensity based on workout volume:

```
Exercise: 3x10 pull ups (3 sets × 10 reps = 30 total reps)
  ↓
Normalized Volume: 30 / 30 = 1.0
  ↓
Distributed across: Lats, Upper Back, Biceps
  ↓
Each muscle gets: 1.0 / 3 = 0.33 intensity
```

### Color Coding

```
Intensity Level    Color      Description
───────────────────────────────────────────
0.00              ⬜ Gray    Not Targeted
0.01 - 0.29       🟡 Yellow  Light Work
0.30 - 0.59       🟠 Orange  Moderate Work
0.60 - 1.00       🔴 Red     Heavy Work
```

## Supported Exercises

### Upper Body
- **Chest**: bench press, push ups, chest press, chest fly, dips
- **Back**: pull ups, rows, deadlifts, lat pulldowns
- **Shoulders**: shoulder press, overhead press, lateral raises
- **Arms**: curls (biceps), tricep extensions

### Lower Body
- **Legs**: squats, lunges, leg press, leg extension, leg curl
- **Calves**: calf raises
- **Glutes**: included in squat/lunge movements

### Core
- **Abs**: planks, crunches, sit ups
- **Obliques**: russian twists, side planks

### Cardio
- **Cardio**: run, cycle, swim, walk, jog, sprint

## Example Output

### Input:
```
Day 1
3x10 pull ups
3x10 dips
50 push ups

Day 2
4x8 bench press
5x5 squats
30 min cycle
```

### Muscle Map Result:
```
🔴 Chest (Heavy)        - bench press, dips, push ups
🔴 Triceps (Heavy)      - dips, push ups, bench press
🟠 Lats (Moderate)      - pull ups
🟠 Upper Back (Moderate)- pull ups
🟠 Biceps (Moderate)    - pull ups
🟠 Quads (Moderate)     - squats
🟠 Glutes (Moderate)    - squats
🟠 Hamstrings (Moderate)- squats
🟡 Shoulders (Light)    - push ups, bench press
🟡 Cardio (Light)       - cycle
⬜ Abs (Not Targeted)
⬜ Calves (Not Targeted)
```

## Visual Body Representation

The body visualization shows:

```
        HEAD
         ○
        
   SHOULDERS (bilateral)
    ◄──┬──┬──►
       │  │
   ARMS (bilateral)
    ◄─┤  ├─►
      │CHEST/BACK│
      │   ABS   │
      └────────┘
      
   LEGS (bilateral)
    ║    ║
    ║    ║  ← QUADS/HAMS
    ╚════╝
```

Each region is:
- Color-coded based on intensity
- Clickable for details (in the breakdown)
- Labeled with muscle name
- Mirrored for bilateral muscles

## Benefits

1. **Visual Feedback**: See at a glance which muscles you've worked
2. **Balance Check**: Identify under-trained muscle groups
3. **Progress Tracking**: Monitor training balance over time
4. **Motivation**: Gamification through "completing" the body map

## Technical Details

- Automatic exercise recognition using keyword matching
- Case-insensitive matching
- Volume-based intensity calculation
- Normalized 0-1 scale for consistent heatmap
- 14 tracked muscle groups + cardio
- 40+ exercise keywords mapped
