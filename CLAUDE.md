# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WordFolly is an iOS word game where players arrange falling letters into a five-letter word. Built using Swift, SpriteKit for game physics, and Firebase for backend services.

## Build and Development Commands

This is an Xcode project. Use Xcode to build and run:
- Open `Game2.xcodeproj` in Xcode
- Select target device/simulator
- Build: ⌘+B
- Run: ⌘+R
- Archive for distribution: Product → Archive

## Architecture

### Core Components

- **GameScene.swift**: Main game logic using SpriteKit physics engine
- **GameMenu.swift**: Menu system with Game Center integration and leaderboards  
- **BoxManager.swift**: Manages stationary letter boxes (5 positions at bottom)
- **FallingBoxManager.swift**: Handles falling letter physics and collision detection
- **GameData.swift**: Data model for daily word puzzles
- **FirebaseManager.swift**: Backend integration for fetching daily puzzles
- **FirebaseScore.swift**: Handles score submission to leaderboards

### Game Flow

1. GameMenu loads daily puzzle from Firebase
2. GameScene initializes with word data and physics world
3. FallingBoxManager spawns falling letters from letterList
4. BoxManager handles collision detection and letter placement in 5 fixed positions
5. Score tracking and Game Center integration for leaderboards

### Firebase Integration

- Daily puzzles stored with date-based queries
- Real-time database for game data fetching
- Analytics and crash reporting
- Authentication for leaderboard scores

### Key Files Structure

```
Game2/
├── GameScene.swift        # Main game physics and logic
├── GameMenu.swift         # Menu and Game Center integration
├── BoxManager.swift       # Word box management
├── FallingBoxManager.swift # Falling word physics
├── FirebaseManager.swift  # Backend data fetching
├── GameData.swift         # Puzzle data model
└── Assets/                # Game sprites, sounds, SKS files
```

### Physics System

- CollisionType enum defines wordBox (1) and fallingBox (4) collision categories
- SKPhysicsWorld handles letter falling and collision detection
- Fixed positions at [-244.0, -122.0, 0.0, 122.0, 244.0] for final letter placement

### Recent Features

- **30-Day Score History Popup**: Interactive popup displaying all 30 days of scores, accessible from main menu via totalScoreLabel tap
- **Visual Feedback for Incorrect Matches**: Target boxes flash orange when falling letters hit the wrong position, providing immediate feedback for mistakes
- **Instructions Popup**: Interactive "How to Play" overlay accessible from both GameScene and GameMenu
- **Automatic Box Bounce**: BoxParent bounces left/right until user takes manual control
- **30-Day Scoring**: True trailing 30-day score including zeros for missed days, with fixed off-by-one error in date filtering
- **Daily Checkbox**: Visual indicator shows if player has completed today's puzzle
- **Status Label**: Shows "READY" or "PLAYED" state on main menu
- **Delayed Exit Button**: Exit button appears 1.3s after game ends for better UX
- **Sparkle Particle Effect**: Start box shows particle effect when ready to play

### Game Mechanics

- **Scoring**: 10 mistakes maximum, lower scores are better
- **Daily Play**: One puzzle per day, tracked with `playedToday` flag
- **30-Day Leaderboard**: Sums past 30 calendar days (including 0s for missed days)
- **Touch Controls**: Drag to move box grid, tap buttons for actions
- **Visual Feedback**: Sound effects, particle explosions, score animations

### Dependencies

- Firebase iOS SDK (v10.0+): Analytics, Auth, Database, Crashlytics
- GameKit for Game Center leaderboards
- SpriteKit for 2D game physics and rendering

### Important Implementation Details

- Daily scoring fills gaps with zeros using `update30DayScore()` in GameScene.swift:276 (renamed from `saveDailyScore()`)
- 30-day score filter uses `>` (not `>=`) to keep exactly 30 days in GameScene.swift:306
- Checkbox visibility updates via `updateCheckboxVisibility()` in GameMenu.swift:339
- Status label shows READY/PLAYED state in GameMenu.swift:343-346
- Instructions popup methods in both GameScene and GameMenu
- Score history popup methods: `setupScoresPopup()`, `showScoresPopup()`, `hideScoresPopup()`, `generateScoresText()` in GameMenu.swift:537+
- Exit button delay in `finalScoreBoxes()` in GameScene.swift:418-423
- Sparkle particle effect setup in `setupStartBoxParticles()` in GameMenu.swift:253+