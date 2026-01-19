# Wayward Wander - Project Status

## Overview
iOS scavenger hunt app that guides users to GPS locations with progressive hints and a compass.

## Current State: v2 Feature Complete
All core features plus enhancements implemented:

### Core Features
- Load hunts from bundled JSON or imported files
- Progressive hint system (text → compass → distance)
- Compass arrow pointing to target location
- GPS arrival detection
- Photo carousel reveals on arrival (swipeable, with page indicators)
- Passcode entry to unlock clues
- Victory screen on completion

### Recent Additions
- **Home Screen**: Hunt selection with branded "Wayward Wander" header and hunt cards
- **Hunt Import**: Import .json or .wwh (zip bundle with images) hunt files
- **Progress Persistence**: Hunt progress saved to UserDefaults
- **Navigation**: Back buttons on all screens to navigate between clues or return to start
- **Background Image**: Custom background image on all screens via `.withAppBackground()` modifier
- **UI Polish**: Thicker borders on UI elements for better visibility
- **Debug Mode**: "Simulate Arrival" button in DEBUG builds for testing without GPS

## Project Structure
```
WaywardWander/
├── WaywardWanderApp.swift           # App entry + ContentView + navigation state machine
├── Models/Hunt.swift                # Data models (Hunt, Clue, Hint, Reveal)
├── Views/
│   ├── HomeView.swift               # Hunt selection screen
│   ├── HuntCardView.swift           # Card component for hunt list
│   ├── HuntIntroView.swift          # Hunt start screen
│   ├── ClueView.swift               # Main gameplay with hint buttons
│   ├── CompassView.swift            # Arrow that points to target
│   ├── RevealView.swift             # Shows discovery content with photo carousel
│   ├── PasscodeView.swift           # Unlock next clue
│   ├── VictoryView.swift            # Hunt complete
│   └── BackgroundView.swift         # Reusable background component
├── Services/
│   ├── LocationManager.swift        # CoreLocation wrapper
│   ├── HuntStore.swift              # Manages bundled + imported hunts
│   ├── HuntProgressManager.swift    # Persists hunt progress to UserDefaults
│   └── HuntImageLoader.swift        # Loads images from Documents or Assets
├── Resources/sample_hunt.json       # 3 San Francisco test locations
└── Assets.xcassets/
    ├── home_background.imageset/    # Custom background image
    └── [location]_[n].imageset/     # Placeholder images for sample hunt
```

## Dependencies
- **ZIPFoundation**: Required for .wwh bundle import (add via Xcode: File > Add Package Dependencies > https://github.com/weichsel/ZIPFoundation)

## Sample Hunt
3 locations in San Francisco: Cable Car Turnaround → Transamerica Pyramid (passcode: "1972") → Ghirardelli Square

## Hunt File Format

### JSON (.json)
Standard hunt definition file.

### Bundle (.wwh)
Zip file containing:
- `hunt.json` - Hunt definition
- `images/` folder - Referenced images

## Testing
- Use "Dev: Simulate Arrival" button in DEBUG builds to test without GPS
- Set simulated location in Xcode for location-based testing
- Import test hunts via Files app or share sheet

## GitHub
https://github.com/Trouble-/WaywardWander
