# System Patterns: Skyland Defenders

## Architecture Overview
The game follows a component-based architecture with distinct systems handling specific game mechanics.

## Core Systems

### Grid System
- Grid-based terrain representation
- Tile-based defender placement
- Collision detection for valid placement

### Combat System
```mermaid
flowchart TD
    D[Defender] --> T[Target Detection]
    T --> R[Range Check]
    R --> A[Attack]
    A --> C[Cooldown]
    C --> T
```

### Enemy AI System
```mermaid
flowchart TD
    S[Spawn] --> P[Pathfinding]
    P --> M[Movement]
    M --> TR[Target Range Check]
    TR --> A[Attack]
    A --> M
```

### Resource Management System
```mermaid
flowchart TD
    ED[Enemy Defeat] --> RG[Resource Generation]
    RG --> RS[Resource Storage]
    RS --> DP[Defender Placement]
    DP --> RC[Resource Consumption]
```

### Wave System
```mermaid
flowchart TD
    S[Start Wave] --> ES[Enemy Spawning]
    ES --> WP[Wave Progress]
    WP --> WC[Wave Complete]
    WC --> NW[Next Wave/Victory]
```

## System Interactions
- Grid system validates defender placement
- Combat system manages attacks and health
- Resource system gates defender placement
- Wave system controls game progression

## Technical Patterns
1. Observer pattern for game events
2. State machine for game flow
3. Component system for entities
4. Factory pattern for entity creation

## Development Guidelines
1. Keep systems modular and independent
2. Use events for cross-system communication
3. Implement clear interfaces between systems
4. Maintain single responsibility principle