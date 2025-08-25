# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Wuhba is an iOS word game where players arrange falling words into a five-word phrase. Built using Swift, SpriteKit for game physics, and Firebase for backend services.

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
- **BoxManager.swift**: Manages stationary word boxes (5 positions at bottom)
- **FallingBoxManager.swift**: Handles falling word physics and collision detection
- **GameData.swift**: Data model for daily word puzzles
- **FirebaseManager.swift**: Backend integration for fetching daily puzzles
- **FirebaseScore.swift**: Handles score submission to leaderboards

### Game Flow

1. GameMenu loads daily puzzle from Firebase
2. GameScene initializes with word data and physics world
3. FallingBoxManager spawns falling words from letterList
4. BoxManager handles collision detection and word placement in 5 fixed positions
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
- SKPhysicsWorld handles word falling and collision detection
- Fixed positions at [-244.0, -122.0, 0.0, 122.0, 244.0] for final word placement

### Dependencies

- Firebase iOS SDK (v10.0+): Analytics, Auth, Database, Crashlytics
- GameKit for Game Center leaderboards
- SpriteKit for 2D game physics and rendering