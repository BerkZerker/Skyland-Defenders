# Skyland Defenders - TODO List

## Completed Tasks ✅

- ✅ Implement component system
- ✅ Fix bugs - health bars not visible, enemy not moving
- ✅ Clean up codebase and organize files into folders
- ✅ Reorganize scenes into proper directories (entities, levels, ui)
- ✅ Standardize naming conventions for scripts and scenes
- ✅ Remove redundant files (standalone implementations)
- ✅ Rename component_*.tscn files to *.tscn
- ✅ Rename component_*.gd files to *.gd
- ✅ Update references in scripts to point to new file locations
- ✅ Fix class name conflicts in scripts

## Phase 1 - Core Gameplay

- Add enemy pathfinding - integrated with tilemap using native godot pathfinding nodes
- Fix touch controls & camera offset
- Make enemies spawn from spawn points (spawn point scene)
- Make resources not hardcoded 
- Add a main tower scene
- Add basic tiles "grass" and "wall", we should also have "king" and "enemy spawn" 
- Get UI working and finish the game loop
- Make customizable debug drawing and settings file (attack radius, etc)
- Clean up export configs - remove web and add android export
- Implement a more robust event system
- Create a configuration system for game settings
- Add save/load functionality

## Phase 2 - Content Expansion

- Add pinch to zoom, swipe to pan gestures
- Add second kind of defender 
- Add basic start screen ui
- Add deck building ui screen
- Add deck to game
- Add multiple enemy types with different behaviors
- Add boss enemies at milestone waves
- Implement component-based UI elements
- Create a component-based level system
- Add component-based visual and audio effects
- Implement more sophisticated AI behaviors as components

## Phase 3 - Polish

- Improve visual effects for attacks
- Add background elements and parallax
- Add sound effects for game actions
- Add background music
- Fine-tune resource economy
- Balance enemy health and damage
- Balance defender costs and attack power
- Improve health bar visualization
- Improve game over and victory screens
- Create a visual editor for component-based entities

## Phase 4 - Release

- Final testing and bug fixes
- Performance optimization
- Deployment preparation
- Create custom level loading functionality
- Create a dedicated level editor scene
