# Skyland Defenders

A 2D tower defense game built with Godot Engine where you defend floating islands in the sky from waves of enemies.

![Skyland Defenders](https://placeholder-for-game-screenshot.png)

## About the Game

In Skyland Defenders, you must strategically place defenders on floating islands to protect against waves of invading enemies. Manage your resources carefully, as each defender costs resources to place. Defeat enemies to earn more resources and survive all waves to achieve victory!

## Features

- **Strategic Tower Defense Gameplay**: Place defenders strategically on a grid-based system to protect your islands
- **Resource Management**: Earn resources by defeating enemies and spend them to place new defenders
- **Wave-Based Progression**: Face increasingly difficult waves of enemies
- **Grid-Based Placement**: Intuitive grid system for placing defenders
- **Victory and Defeat Conditions**: Win by surviving all waves or lose if all your defenders are destroyed
- **Component-Based Architecture**: Entities are built using a flexible component system for better code organization and reusability

## How to Play

### Requirements

- Godot Engine 4.x

### Running the Game

1. Clone this repository
2. Open the project in Godot Engine
3. Press F5 or click the "Play" button in the editor

### Controls

- **Left Mouse Button/Touch**: Place defenders during placement mode, interact with UI
- **Start Wave Button**: Begin the next wave of enemies
- **Pause Button**: Pause/resume the game
- **Restart Button**: Reset the game to its initial state

## Development

Skyland Defenders is currently in Phase 1 of development, focusing on implementing core gameplay mechanics. See [PROJECT_STATUS.md](PROJECT_STATUS.md) for detailed information about the current development status, implemented features, and planned features.

### Project Structure

- `scenes/`: Game scenes
  - `scenes/entities/`: Entity scenes (defender, enemy, projectile)
  - `scenes/levels/`: Level scenes
  - `scenes/ui/`: UI-related scenes
- `scripts/`: GDScript files
  - `scripts/components/`: Component system base classes and standard components
  - `scripts/entities/`: Entity scripts that use the component system
  - `scripts/managers/`: Manager scripts for different game systems
  - `scripts/systems/`: Core game systems
  - `scripts/ui/`: UI-related scripts
- `assets/`: Graphics, sounds, and other resources

### Key Files
- `scenes/game.tscn`: Main game scene
- `scenes/levels/level.tscn`: Level scene with navigation
- `scripts/game.gd`: Main game logic
- `scripts/components/entity.gd`: Base class for all entities
- `scripts/components/component.gd`: Base class for all components

### Component Architecture

Skyland Defenders uses a component-based architecture where game entities are composed of smaller, reusable components. This architecture follows these core principles:

1. **Composition over Inheritance**: Build entities by composing multiple components rather than using deep inheritance hierarchies.
2. **Single Responsibility**: Each component has a single responsibility.
3. **Loose Coupling**: Components communicate through signals or well-defined interfaces.
4. **Reusability**: Components are designed to be reused across different entity types.

#### Standard Components

- **HealthComponent**: Manages health, damage, and death
- **AttackComponent**: Handles attack logic, damage, and cooldowns
- **TargetingComponent**: Finds and tracks targets
- **MovementComponent**: Handles movement logic
- **VisualComponent**: Manages visual representation
- **CollisionComponent**: Handles collision detection
- **PlacementComponent**: Manages grid-based placement
- **ProjectileComponent**: Handles projectile behavior
- **PathfindingComponent**: Handles pathfinding for entities
- **HealthBarComponent**: Manages health bar visualization

#### Component Communication

Components can communicate in several ways:

1. **Direct References**: Components can access other components through the entity's `get_component()` method.
2. **Signals**: Components can emit signals that other components or the entity can connect to.
3. **Entity Mediation**: The entity can mediate communication between components.

See [TODO.md](TODO.md) for the current development roadmap and [PROJECT_STATUS.md](PROJECT_STATUS.md) for the current project status.

## Debugging Tips

### Common Issues
- If entities aren't appearing, check if they're being added to the correct parent node
- If components aren't working, verify they're being properly initialized and added to the entity
- If signals aren't firing, ensure they're properly connected

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

- Developed by: [Your Name/Team]
- Built with [Godot Engine](https://godotengine.org/)
