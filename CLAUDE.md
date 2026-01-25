# Wayward Wander - Project Status

## Overview
iOS scavenger hunt app that guides users to GPS locations with progressive hints and a compass.

## Current State: v4
All core features plus quest creation/editing with anti-cheat and help options:

### Core Features
- Load journeys from imported files or user-created quests
- Progressive hint system (text → compass → distance)
- Compass arrow pointing to target location ("Follow the arrow")
- GPS arrival detection
- Photo carousel reveals on arrival (swipeable, with page indicators)
- Passcode entry to unlock clues
- Victory screen on completion

### Quest Creator
- Create new quests with title, description, and multiple clues
- Edit existing editable quests (long-press context menu)
- Location picker with GPS capture or manual coordinate entry
- Photo picker for reveal images (library or camera)
- Hints editor (text, compass, distance types)
- Arrival radius slider (5-100m)
- Unlock type selection (automatic or passcode)
- **Help Button** option per clue (None / Allow Skip / Password Required)
- Validation before saving
- Export/share quests as .wwh bundles
- Delete quests via context menu

### Anti-Cheat System
- `isEditable` property on quests controls edit access
- User-created quests are editable by default
- Exported quests have `isEditable = false` (recipients can't cheat by viewing answers)
- Completing a quest unlocks editing (so you can see how it was built)
- Share and Delete always available; Edit only when editable

### Other Features
- **Home Screen**: Journey selection with branded "Wayward Wander" header and quest cards
- **Journey Import**: Import .json or .wwh (zip bundle with images) journey files
- **Progress Persistence**: Journey progress saved to UserDefaults
- **Navigation**: "Home" and "Previous" buttons on all screens
- **"Stuck?" Button**: Optional help button when GPS arrival doesn't trigger
- **Background Image**: Custom background on all screens via `.withAppBackground()` modifier
- **Custom Color Scheme** (defined in Theme.swift)
- **App Icon**: Custom app icon (ww_icon.png)
- **Debug Mode**: "Simulate Arrival" button in DEBUG builds

## Project Structure
```
WaywardWander/
├── WaywardWanderApp.swift           # App entry + ContentView + navigation state machine
├── Theme.swift                      # Centralized color definitions (AppTheme)
├── Models/
│   ├── Hunt.swift                   # Data models (Hunt, Clue, Hint, Reveal)
│   └── EditableHunt.swift           # Mutable models for quest editing
├── Views/
│   ├── HomeView.swift               # Journey selection + create/import buttons
│   ├── HuntCardView.swift           # Card component with context menu actions
│   ├── HuntIntroView.swift          # Journey start screen ("Begin Journey")
│   ├── ClueView.swift               # Main gameplay with hint buttons
│   ├── CompassView.swift            # Arrow that points to target
│   ├── RevealView.swift             # Shows discovery content with photo carousel
│   ├── PasscodeView.swift           # Unlock next clue
│   ├── VictoryView.swift            # Journey complete
│   ├── BackgroundView.swift         # Reusable background component
│   └── Editor/
│       ├── QuestEditorView.swift    # Main quest editor container
│       ├── ClueEditorView.swift     # Single clue editor
│       ├── LocationPickerView.swift # GPS capture + manual coordinates
│       └── PhotoPickerView.swift    # Photo selection/capture for reveals
├── Services/
│   ├── LocationManager.swift        # CoreLocation wrapper
│   ├── HuntStore.swift              # Manages quests: load, save, import, export
│   ├── HuntProgressManager.swift    # Persists journey progress to UserDefaults
│   └── HuntImageLoader.swift        # Loads images from Documents or Assets
└── Assets.xcassets/
    ├── AppIcon.appiconset/          # App icon (ww_icon.png)
    └── home_background.imageset/    # Custom background image
```

## Dependencies
- **ZIPFoundation**: Required for .wwh bundle import/export (add via Xcode: File > Add Package Dependencies > https://github.com/weichsel/ZIPFoundation)

## User-Created Quest Storage
```
Documents/Hunts/
└── [quest-id]/
    ├── hunt.json          # Quest definition
    └── images/
        ├── photo_abc123.jpg
        └── ...
```

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
