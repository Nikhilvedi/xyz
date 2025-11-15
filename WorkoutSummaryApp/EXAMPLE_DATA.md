# Example Data Structures

This document shows the expected data output from the parser in JSON-like format.

## Example 1: Basic Workout

### Input Text:
```
Day 1
3x10 pull ups
3x10 dips
5k run
```

### Parsed Output (JSON representation):
```json
[
  {
    "id": "UUID-123",
    "dateLabel": "Day 1",
    "exercises": [
      {
        "id": "UUID-456",
        "rawText": "3x10 pull ups",
        "sets": 3,
        "reps": 10,
        "quantity": null,
        "unit": null,
        "movement": "pull ups"
      },
      {
        "id": "UUID-789",
        "rawText": "3x10 dips",
        "sets": 3,
        "reps": 10,
        "quantity": null,
        "unit": null,
        "movement": "dips"
      },
      {
        "id": "UUID-ABC",
        "rawText": "5k run",
        "sets": null,
        "reps": null,
        "quantity": 5.0,
        "unit": "k",
        "movement": "run"
      }
    ]
  }
]
```

## Example 2: Multiple Days

### Input Text:
```
Day 1
3x10 pull ups
3x10 dips
5k run

Day 2
4x8 bench press
30 min cycle
```

### Parsed Output:
```json
[
  {
    "id": "UUID-1",
    "dateLabel": "Day 1",
    "exercises": [
      {
        "id": "UUID-1a",
        "rawText": "3x10 pull ups",
        "sets": 3,
        "reps": 10,
        "quantity": null,
        "unit": null,
        "movement": "pull ups"
      },
      {
        "id": "UUID-1b",
        "rawText": "3x10 dips",
        "sets": 3,
        "reps": 10,
        "quantity": null,
        "unit": null,
        "movement": "dips"
      },
      {
        "id": "UUID-1c",
        "rawText": "5k run",
        "sets": null,
        "reps": null,
        "quantity": 5.0,
        "unit": "k",
        "movement": "run"
      }
    ]
  },
  {
    "id": "UUID-2",
    "dateLabel": "Day 2",
    "exercises": [
      {
        "id": "UUID-2a",
        "rawText": "4x8 bench press",
        "sets": 4,
        "reps": 8,
        "quantity": null,
        "unit": null,
        "movement": "bench press"
      },
      {
        "id": "UUID-2b",
        "rawText": "30 min cycle",
        "sets": null,
        "reps": null,
        "quantity": 30.0,
        "unit": "min",
        "movement": "cycle"
      }
    ]
  }
]
```

## Example 3: Various Date Formats

### Input Text:
```
Monday
3x10 squats

17/11/25
4x8 deadlifts

2025-11-19
5x5 overhead press

20 Nov
50 push ups
```

### Parsed Output:
```json
[
  {
    "id": "UUID-A",
    "dateLabel": "Monday",
    "exercises": [
      {
        "id": "UUID-A1",
        "rawText": "3x10 squats",
        "sets": 3,
        "reps": 10,
        "quantity": null,
        "unit": null,
        "movement": "squats"
      }
    ]
  },
  {
    "id": "UUID-B",
    "dateLabel": "17/11/25",
    "exercises": [
      {
        "id": "UUID-B1",
        "rawText": "4x8 deadlifts",
        "sets": 4,
        "reps": 8,
        "quantity": null,
        "unit": null,
        "movement": "deadlifts"
      }
    ]
  },
  {
    "id": "UUID-C",
    "dateLabel": "2025-11-19",
    "exercises": [
      {
        "id": "UUID-C1",
        "rawText": "5x5 overhead press",
        "sets": 5,
        "reps": 5,
        "quantity": null,
        "unit": null,
        "movement": "overhead press"
      }
    ]
  },
  {
    "id": "UUID-D",
    "dateLabel": "20 Nov",
    "exercises": [
      {
        "id": "UUID-D1",
        "rawText": "50 push ups",
        "sets": null,
        "reps": 50,
        "quantity": null,
        "unit": null,
        "movement": "push ups"
      }
    ]
  }
]
```

## Example 4: All Exercise Types

### Input Text:
```
Day 1
3x10 pull ups      (strength sets)
4 x 8 bench press  (strength sets with spaces)
50 push ups        (bodyweight reps)
max pull ups       (max reps)
5k run             (cardio distance - k)
3 km row           (cardio distance - km)
30 min cycle       (cardio time)
```

### Parsed Output:
```json
[
  {
    "id": "UUID-X",
    "dateLabel": "Day 1",
    "exercises": [
      {
        "id": "UUID-X1",
        "rawText": "3x10 pull ups",
        "sets": 3,
        "reps": 10,
        "quantity": null,
        "unit": null,
        "movement": "pull ups"
      },
      {
        "id": "UUID-X2",
        "rawText": "4 x 8 bench press",
        "sets": 4,
        "reps": 8,
        "quantity": null,
        "unit": null,
        "movement": "bench press"
      },
      {
        "id": "UUID-X3",
        "rawText": "50 push ups",
        "sets": null,
        "reps": 50,
        "quantity": null,
        "unit": null,
        "movement": "push ups"
      },
      {
        "id": "UUID-X4",
        "rawText": "max pull ups",
        "sets": null,
        "reps": null,
        "quantity": null,
        "unit": null,
        "movement": "pull ups"
      },
      {
        "id": "UUID-X5",
        "rawText": "5k run",
        "sets": null,
        "reps": null,
        "quantity": 5.0,
        "unit": "k",
        "movement": "run"
      },
      {
        "id": "UUID-X6",
        "rawText": "3 km row",
        "sets": null,
        "reps": null,
        "quantity": 3.0,
        "unit": "km",
        "movement": "row"
      },
      {
        "id": "UUID-X7",
        "rawText": "30 min cycle",
        "sets": null,
        "reps": null,
        "quantity": 30.0,
        "unit": "min",
        "movement": "cycle"
      }
    ]
  }
]
```

## Example 5: With Commentary (Filtered Out)

### Input Text:
```
Day 1
felt great today
3x10 pull ups
need to work on form
3x10 dips
did some stretching
5k run
recovery day
```

### Parsed Output:
```json
[
  {
    "id": "UUID-Y",
    "dateLabel": "Day 1",
    "exercises": [
      {
        "id": "UUID-Y1",
        "rawText": "3x10 pull ups",
        "sets": 3,
        "reps": 10,
        "quantity": null,
        "unit": null,
        "movement": "pull ups"
      },
      {
        "id": "UUID-Y2",
        "rawText": "3x10 dips",
        "sets": 3,
        "reps": 10,
        "quantity": null,
        "unit": null,
        "movement": "dips"
      },
      {
        "id": "UUID-Y3",
        "rawText": "5k run",
        "sets": null,
        "reps": null,
        "quantity": 5.0,
        "unit": "k",
        "movement": "run"
      }
    ]
  }
]
```

Note: Lines like "felt great today", "need to work on form", "did some stretching", and "recovery day" are ignored because they don't match any exercise pattern.

## Data Model Mapping

### Swift Structs → JSON

```swift
struct WorkoutDay: Identifiable {
    let id = UUID()              // "id": "UUID-string"
    let dateLabel: String         // "dateLabel": "Day 1"
    var exercises: [Exercise]     // "exercises": [...]
}

struct Exercise: Identifiable {
    let id = UUID()              // "id": "UUID-string"
    let rawText: String          // "rawText": "3x10 pull ups"
    let sets: Int?               // "sets": 3 or null
    let reps: Int?               // "reps": 10 or null
    let quantity: Double?        // "quantity": 5.0 or null
    let unit: String?            // "unit": "k" or null
    let movement: String         // "movement": "pull ups"
}
```

## Field Usage by Exercise Type

| Exercise Type | sets | reps | quantity | unit | movement |
|--------------|------|------|----------|------|----------|
| Strength Sets | ✓ | ✓ | - | - | ✓ |
| Bodyweight Reps | - | ✓ | - | - | ✓ |
| Max Reps | - | - | - | - | ✓ |
| Cardio Distance | - | - | ✓ | ✓ | ✓ |
| Cardio Time | - | - | ✓ | ✓ | ✓ |

Legend:
- ✓ = Field is populated
- - = Field is null/nil

## Edge Cases

### Empty Input
```
Input: ""
Output: []
```

### Only Day Headers
```
Input: "Day 1\nDay 2"
Output: [
  {"dateLabel": "Day 1", "exercises": []},
  {"dateLabel": "Day 2", "exercises": []}
]
```

### No Day Headers (Orphaned Exercises)
```
Input: "3x10 pull ups\n5k run"
Output: []
```
Note: Exercises without a day header are ignored.

### Mixed Valid and Invalid Lines
```
Input: 
"Day 1
3x10 pull ups
some random text
5k run
another comment"

Output: [
  {
    "dateLabel": "Day 1",
    "exercises": [
      {"rawText": "3x10 pull ups", ...},
      {"rawText": "5k run", ...}
    ]
  }
]
```
