# Active Context: Skyland Defenders

## Current Focus
Implementing Phase 1: Core Gameplay Prototype (MVP)

## Implementation Order
1. **Defender Placement System** (Current Priority)
   - Grid-based placement
   - Tile validation
   - Basic defender instantiation

2. **Enemy Movement & Pathfinding**
   - Basic pathfinding implementation
   - Enemy movement towards defenders
   - Path recalculation

3. **Defender Attacking Mechanics**
   - Range-based targeting
   - Basic projectile system
   - Attack cooldown

4. **Enemy Attacking Mechanics**
   - Melee range detection
   - Damage system
   - Attack animations

5. **Resource System**
   - Resource tracking
   - Enemy defeat rewards
   - Placement cost system

6. **Game Loop**
   - Wave spawning system
   - Victory/defeat conditions
   - Game state management

7. **Basic UI**
   - Core game controls
   - Resource display
   - Health/wave indicators

## Active Decisions
1. Using grid-based system for precise placement
2. Implementing A* pathfinding for enemies
3. Using signal system for event handling
4. Centralizing resource management

## Current Considerations
1. Grid size optimization for mobile
2. Enemy spawn point placement
3. Resource balance for initial prototype
4. UI scaling for different devices

## Next Steps
1. Set up basic grid system
2. Implement defender placement logic
3. Add placement validation
4. Create basic defender entity