This file lists the features required for this 2d tower defense mobile game.

### Phase 1: Core Gameplay Prototype (Minimal Viable Product)

#### Objective

Implement the most basic tower defense mechanics with a single defender and enemy type.

#### Features to Implement

**Basic Game Loop**

- Start game
- Spawn enemies in waves
- Player places a single type of defender
- Enemies attack defenders
- If all defenders are killed, the game ends
- Victory condition: survive X waves

**Defender System**

- One ranged defender with a basic attack
- Automatic targeting of the closest enemy
- Attack cooldown

**Enemy System**

- One melee enemy type
- Pathfinding towards defenders
- Attacks when in range

**Map & Placement System**

- Basic floating island terrain
- Grid-based placement system for defenders 

**Basic Resource System**

- Defeating enemies generates resources
- Resources allow placing new defenders

**Basic UI**

- Start, Pause, Restart buttons
- Health bars for defenders and enemies
- Resource counter
- Wave counter

#### Implementation Order

1. Defender placement system
2. Enemy movement & pathfinding
3. Defender attacking mechanics
4. Enemy attacking mechanics
5. Resource system
6. Game loop (start, win/lose conditions)
7. Basic UI elements

