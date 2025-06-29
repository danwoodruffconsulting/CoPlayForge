<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# CoPlayForge Development Instructions

## Project Overview
CoPlayForge is a tactical RPG built in Godot 4 with the following key characteristics:
- Low-stat character design emphasizing group synergy over individual power
- AI-driven hero behavior with customizable tactics
- 100 unique hero classes with diverse abilities
- Real-time combat with tactical pause capabilities
- Web browser deployment target

## Code Style Guidelines

### GDScript Conventions
- Use `class_name` for all reusable classes
- Prefer `@export` for inspector-visible properties
- Use type hints for all variables and function parameters
- Follow snake_case for variables and functions, PascalCase for classes
- Group related functionality into singletons for global systems

### Architecture Patterns
- **Singleton Pattern**: Use for managers (GameManager, CombatManager, AudioManager)
- **Component System**: Units are composed of data classes (HeroData, Stats, Equipment)
- **Observer Pattern**: Leverage Godot signals for loose coupling between systems
- **State Machine**: Implement game states and AI behaviors as finite state machines

## Key Systems

### Combat System
- Turn-based with initiative order based on speed stats
- Synergy bonuses calculated based on unit proximity and class combinations
- Low base damage (5-10) with minimal armor to emphasize positioning and tactics

### AI Behavior
- Behavior trees for complex decision making
- Customizable priority systems for different playstyles
- Formation preferences and positioning logic
- Support for both player-controlled and enemy AI

### Class System
- 100 unique hero classes with 1-3 abilities each
- Base stats intentionally low (20 HP, 5 ATK, 3 DEF)
- Slow progression focusing on unlocking new abilities rather than stat growth
- Synergy bonuses between complementary classes

## Development Priorities

### Performance Considerations
- Target web browser deployment - optimize for WebGL2
- Use object pooling for frequently created/destroyed objects
- Minimize memory allocations during combat
- Efficient pathfinding and AI decision algorithms

### User Experience
- Clear visual feedback for synergy bonuses and formations
- Intuitive camera controls for 3D tactical view
- Responsive UI that works across different screen sizes
- Audio feedback for all player actions

### Code Organization
- Keep data classes (HeroData, Stats, etc.) separate from behavior
- Use composition over inheritance for unit capabilities
- Implement clear separation between game logic and presentation
- Maintain backwards compatibility for save data structures

## Testing Guidelines
- Focus on combat balance and AI behavior validation
- Test synergy calculations with various party compositions
- Verify performance with maximum unit counts (8v8 battles)
- Validate web export functionality regularly

## Asset Requirements
- Cartoon-style 3D models compatible with Godot 4
- Chiptune audio in OGG format for web compatibility
- Simple geometric shapes acceptable for prototyping
- UI elements should scale appropriately for different resolutions

When generating code for this project, prioritize:
1. Clear, maintainable architecture
2. Performance optimization for web deployment
3. Extensible systems that can accommodate all 100 hero classes
4. Rich tactical gameplay mechanics
5. Robust AI behavior systems
