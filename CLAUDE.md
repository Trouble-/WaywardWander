# Wayward Wander - Project Status

## Overview
iOS scavenger hunt app that guides users to GPS locations with progressive hints and a compass.

## Current State: v1 Prototype Complete
All core features implemented and ready for testing:
- Load hunts from bundled JSON
- Progressive hint system (text → compass → distance)
- Compass arrow pointing to target location
- GPS arrival detection
- Photo/text reveals on arrival
- Passcode entry to unlock clues
- Victory screen on completion

## Project Structure
```
WaywardWander/
├── WaywardWanderApp.swift      # App entry + ContentView + navigation state machine
├── Models/Hunt.swift           # Data models (Hunt, Clue, Hint, Reveal)
├── Views/
│   ├── HuntIntroView.swift     # Start screen
│   ├── ClueView.swift          # Main gameplay with hint buttons
│   ├── CompassView.swift       # Arrow that points to target
│   ├── RevealView.swift        # Shows discovery content
│   ├── PasscodeView.swift      # Unlock next clue
│   └── VictoryView.swift       # Hunt complete
├── Services/LocationManager.swift  # CoreLocation wrapper
├── Resources/sample_hunt.json      # 3 San Francisco test locations
└── Info.plist                      # Location permission descriptions
```

## Sample Hunt
3 locations in San Francisco: Cable Car Turnaround → Transamerica Pyramid (passcode: "1972") → Ghirardelli Square

## Next Steps
- Test in Xcode simulator with simulated location
- Test on physical device for real compass/GPS
- Customize sample_hunt.json with your own locations
- Add actual photos to Assets.xcassets for reveals

## GitHub
https://github.com/Trouble-/WaywardWander
