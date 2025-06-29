# Contributing to CoPlayForge

Thank you for your interest in contributing to CoPlayForge! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and constructive in all interactions
- Focus on what's best for the community and the project
- Welcome newcomers and help them get started

## How to Contribute

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Use clear, descriptive titles
3. Include steps to reproduce the problem
4. Mention your Godot version and operating system

### Suggesting Features

1. Check if the feature has already been suggested
2. Explain the use case and benefits
3. Consider how it fits with the game's design philosophy

### Code Contributions

#### Getting Started

1. Fork the repository
2. Clone your fork locally
3. Open the project in Godot 4.3+
4. Create a new branch for your feature/fix

#### Development Guidelines

- Follow the existing code style and conventions
- Use `class_name` for all reusable classes
- Add type hints to all variables and function parameters
- Write clear, descriptive commit messages
- Test your changes thoroughly

#### Hero Class Contributions

When adding new hero classes:

1. Add the class to the `HeroClass.Type` enum
2. Implement `get_class_name()` and `get_class_description()`
3. Define base stats following the low-stat philosophy
4. Create 1-3 unique abilities for the class
5. Consider synergy relationships with existing classes

#### Pull Request Process

1. Update documentation if needed
2. Ensure all tests pass
3. Update the README if you've added features
4. Submit a pull request with a clear description

## Project Structure

```
├── scenes/          # Game scenes (.tscn files)
├── scripts/         # GDScript files
│   ├── singletons/  # Global managers
│   ├── data/        # Data classes
│   ├── units/       # Unit-related scripts
│   └── ai/          # AI behavior scripts
├── audio/           # Sound effects and music
├── materials/       # 3D materials
└── models/          # 3D models and textures
```

## Design Philosophy

### Low Individual Power
- Keep base stats low (around 20 HP, 5 ATK)
- Focus on tactical options over raw power
- Meaningful but slow progression

### Group Synergy
- Classes should work better together
- Positioning and formation matter
- Isolated units should be vulnerable

### AI Partnership
- AI should assist, not replace player decisions
- Customizable behavior priorities
- Clear feedback on AI actions

## Questions?

Feel free to open an issue for questions or join our discussions in the project's GitHub Discussions section.
