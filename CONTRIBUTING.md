# Contributing to History of Everything

Thank you for your interest in contributing to the History of Everything project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## Getting Started

1. Fork the repository
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/HistoryOfEverything.git
   cd HistoryOfEverything
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/jjzhang2000/HistoryOfEverything.git
   ```

## Development Setup

### Prerequisites

- Flutter SDK (>=3.0.0 <4.0.0)
- Dart SDK (comes with Flutter)
- Android Studio / VS Code with Flutter extension
- Xcode (for iOS development, macOS only)
- Android SDK (for Android development)

### Installation

1. Navigate to the app directory:
   ```bash
   cd app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

## Project Structure

```
app/lib/
├── main.dart                    # Application entry point
├── bloc_provider.dart           # State management (InheritedWidget)
├── colors.dart                  # Color constants
├── search_manager.dart          # Search functionality
│
├── animation/                   # Animation components
├── article/                     # Article detail pages
├── blocs/                       # BLoC state management
├── main_menu/                   # Main menu components
├── providers/                   # Riverpod providers
├── l10n/                        # Localization
└── timeline/                    # Timeline core module
    ├── timeline.dart            # Core logic
    ├── timeline_constants.dart  # Layout constants
    ├── timeline_viewport.dart   # Viewport management
    └── timeline_color_manager.dart  # Color management
```

## Coding Standards

### Dart Style Guide

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` to format your code
- Maximum line length: 80 characters

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` (prefer `const` for compile-time constants)

### Documentation

- Document all public APIs using dartdoc comments (`///`)
- Keep comments in English
- Avoid inline comments that explain what the code does; explain why instead

Example:
```dart
/// Calculates the interpolated color at the given position.
///
/// Returns null if there are no colors to interpolate.
Color? interpolateColor(double position) {
  // Implementation...
}
```

### Error Handling

- Use proper error handling with try-catch for async operations
- Provide user-friendly error messages
- Log errors using `debugPrint` for debugging

### Null Safety

- Never use `!` (force unwrap) unless absolutely necessary
- Use `?.` for safe access
- Provide sensible default values with `??`

## Commit Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or modifying tests
- `chore`: Changes to build process or auxiliary tools

### Examples

```
feat(timeline): add zoom animation for timeline navigation

fix(search): resolve crash when searching with empty query

docs(readme): update installation instructions
```

## Pull Request Process

1. Create a feature branch from `Upgrade`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit them following the commit guidelines.

3. Push your branch to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request on GitHub.

5. Ensure all checks pass:
   - Code analysis (`flutter analyze`)
   - Tests (`flutter test`)
   - Build verification

6. Request review from maintainers.

7. Address review feedback.

### PR Checklist

- [ ] Code follows the project's coding standards
- [ ] All tests pass
- [ ] New code is properly documented
- [ ] Commit messages follow the guidelines
- [ ] PR description clearly describes the changes

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

1. **Description**: A clear description of the bug
2. **Steps to Reproduce**: Detailed steps to reproduce the issue
3. **Expected Behavior**: What you expected to happen
4. **Actual Behavior**: What actually happened
5. **Environment**: 
   - Flutter version (`flutter --version`)
   - Device/Platform
   - App version
6. **Screenshots**: If applicable
7. **Logs**: Any relevant error logs

### Feature Requests

For feature requests, please include:

1. **Description**: A clear description of the feature
2. **Use Case**: Why this feature would be useful
3. **Proposed Solution**: If you have ideas for implementation
4. **Alternatives**: Any alternative solutions considered

## Questions?

If you have questions about contributing, feel free to open an issue with the `question` label.

Thank you for contributing to History of Everything!