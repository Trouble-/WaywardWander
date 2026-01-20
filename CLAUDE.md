# Wayward Wander - Project Status

## Overview
iOS scavenger hunt app that guides users to GPS locations with progressive hints and a compass.

## Current State: v2 Feature Complete
All core features plus enhancements implemented:

### Core Features
- Load journeys from bundled JSON or imported files
- Progressive hint system (text → compass → distance)
- Compass arrow pointing to target location
- GPS arrival detection
- Photo carousel reveals on arrival (swipeable, with page indicators)
- Passcode entry to unlock clues
- Victory screen on completion

### Recent Additions
- **Home Screen**: Journey selection with branded "Wayward Wander" header and quest cards
- **Journey Import**: Import .json or .wwh (zip bundle with images) journey files
- **Progress Persistence**: Journey progress saved to UserDefaults
  - Arrival state persists for completed clues
  - Passcodes only need to be entered once
- **Navigation**: "Previous" buttons on all screens to navigate through all pages (Clues and Discovery pages)
- **Background Image**: Custom background image on all screens via `.withAppBackground()` modifier
- **Custom Color Scheme** (defined in Theme.swift):
  - Primary accent: Dark teal
  - Success/arrival: Mint green (#3DB489)
  - Info/hints: Cobalt blue (#1338BE)
  - Trophy: Harvest gold (#DA9100)
- **App Icon**: Custom app icon (ww_icon.png)
- **UI Polish**: Thicker borders on UI elements for better visibility
- **Debug Mode**: "Simulate Arrival" button in DEBUG builds for testing without GPS

## Project Structure
```
WaywardWander/
├── WaywardWanderApp.swift           # App entry + ContentView + navigation state machine
├── Theme.swift                      # Centralized color definitions (AppTheme)
├── Models/Hunt.swift                # Data models (Hunt, Clue, Hint, Reveal)
├── Views/
│   ├── HomeView.swift               # Journey selection screen
│   ├── HuntCardView.swift           # Card component for journey list
│   ├── HuntIntroView.swift          # Journey start screen ("Begin Journey")
│   ├── ClueView.swift               # Main gameplay with hint buttons
│   ├── CompassView.swift            # Arrow that points to target
│   ├── RevealView.swift             # Shows discovery content with photo carousel
│   ├── PasscodeView.swift           # Unlock next clue
│   ├── VictoryView.swift            # Journey complete
│   └── BackgroundView.swift         # Reusable background component
├── Services/
│   ├── LocationManager.swift        # CoreLocation wrapper
│   ├── HuntStore.swift              # Manages bundled + imported journeys
│   ├── HuntProgressManager.swift    # Persists journey progress to UserDefaults
│   └── HuntImageLoader.swift        # Loads images from Documents or Assets
├── Resources/sample_hunt.json       # 3 San Francisco test locations
└── Assets.xcassets/
    ├── AppIcon.appiconset/          # App icon (ww_icon.png)
    ├── home_background.imageset/    # Custom background image
    └── [location]_[n].imageset/     # Placeholder images for sample hunt
```

## Dependencies
- **ZIPFoundation**: Required for .wwh bundle import (add via Xcode: File > Add Package Dependencies > https://github.com/weichsel/ZIPFoundation)

## Sample Hunt
3 locations in San Francisco: Cable Car Turnaround → Transamerica Pyramid (passcode: "1972") → Ghirardelli Square

## Journey File Format

### JSON (.json)
Standard journey definition file.

### Bundle (.wwh)
Zip file containing:
- `hunt.json` - Journey definition
- `images/` folder - Referenced images

## Testing
- Use "Dev: Simulate Arrival" button in DEBUG builds to test without GPS
- Set simulated location in Xcode for location-based testing
- Import test journeys via Files app or share sheet

## GitHub
https://github.com/Trouble-/WaywardWander
