# CoPlayForge - Tactical RPG

A tactical RPG inspired by Shining Force, built with Godot 4, featuring low-stat characters that rely on group synergy and AI-driven behavior.

## Game Features

### Core Concept
- **Low-stat Design**: Heroes and enemies have minimal individual stats, emphasizing teamwork over individual power
- **Group Synergy**: Characters gain bonuses when positioned and coordinated properly with complementary classes
- **AI-Assisted Gameplay**: AI helps manage hero behavior with customizable tactics and priorities
- **100 Unique Classes**: Diverse hero classes each with unique abilities and synergy combinations

### Combat System
- **Real-time Combat**: Fast-paced tactical battles with pause-and-plan capabilities
- **Formation Tactics**: Positioning and group composition directly affect combat effectiveness
- **Ability Combos**: Heroes can chain abilities for devastating combination attacks
- **Dynamic Battlefields**: 3D environments with elevation, obstacles, and environmental hazards

### Hero Classes
The game features 100 unique hero classes across various archetypes:
- **Frontline Fighters**: Warrior, Knight, Paladin, Berserker, Samurai
- **Ranged Attackers**: Archer, Gunslinger, Storm Archer, Frost Archer
- **Magic Users**: Mage, Elementalist, Pyromancer, Cryomancer, Stormcaller
- **Support Classes**: Healer, Priest, Bard, Oracle, Sage
- **Stealth Units**: Rogue, Assassin, Shadowblade, Nightblade
- **Summoners**: Summoner, Necromancer, Beastmaster, Wyrmcaller
- **Specialists**: Engineer, Alchemist, Artificer, Runekeeper
- And many more unique combinations!

## Technical Details

### Platform
- **Engine**: Godot 4.3
- **Target Platform**: Web browsers (HTML5 export)
- **Graphics**: 3D rendering with cartoon-style visuals
- **Audio**: Chiptune soundtrack with retro sound effects

### Development Setup

#### Prerequisites
- Godot 4.3 or later
- Modern web browser for testing

#### Running the Project
1. Open the project in Godot
2. Set the main scene to `scenes/Main.tscn`
3. Press F5 to run the project
4. For web export, configure HTML5 export settings and deploy

#### Project Structure
```
├── scenes/          # Game scenes
├── scripts/         # GDScript files
│   ├── singletons/  # Global managers
│   ├── data/        # Data classes
│   ├── units/       # Unit-related scripts
│   └── ai/          # AI behavior scripts
├── audio/           # Sound effects and music
├── materials/       # 3D materials
└── models/          # 3D models and textures
```

### Key Systems

#### Combat Manager
Handles turn-based combat, unit management, and win/lose conditions.

#### AI Behavior Trees
Sophisticated AI system allowing players to customize hero behavior patterns.

#### Synergy System
Dynamic bonus calculation based on party composition and positioning.

#### Class System
Comprehensive hero class system with 100 unique classes and abilities.

## Game Design Philosophy

### Low Individual Power
- Base stats are intentionally low (20 HP, 5 attack, etc.)
- Progression is slow and meaningful
- Equipment provides tactical options rather than raw power

### Group Dependency
- Isolated units are vulnerable
- Group formations provide significant bonuses
- Class combinations unlock powerful synergies

### AI Partnership
- Players set high-level tactics and priorities
- AI handles micro-management and execution
- Focus on strategic decision-making over unit micromanagement

## Future Development

### Planned Features
- Campaign mode with branching storylines
- Multiplayer battles
- Advanced formation editor
- Custom hero class creator
- Workshop integration for sharing custom content

### Expansion Classes
Additional hero classes and cross-class combinations for even deeper strategic gameplay.

## Contributing

This project is designed as a showcase of tactical RPG mechanics in Godot. Contributions welcome for:
- Additional hero classes and abilities
- AI behavior improvements
- Visual and audio enhancements
- Performance optimizations

## License

This project is created for educational and demonstration purposes.
