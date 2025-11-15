# Contributing to Kharag SDK

Thank you for considering contributing to Kharag SDK! We welcome contributions from the community and are grateful for your support.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to support@example.com.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Environment details**:
  - Flutter version
  - Dart version
  - Platform (iOS/Android)
  - Device/Emulator
  - SDK version

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** for the enhancement
- **Expected behavior**
- **Mockups or examples** (if applicable)

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## Development Setup

### Prerequisites

- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.0.0)
- IDE (VS Code, Android Studio, or IntelliJ IDEA)
- Git

### Setup Steps

1. **Clone the repository**:
```bash
git clone https://github.com/CodingWithTashi/TibetanLanguageLearningApp.git
cd TibetanLanguageLearningApp/packages/kharag_sdk
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run code generation**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run tests**:
```bash
flutter test
```

5. **Run the example app**:
```bash
cd example
flutter run
```

### Project Structure

```
kharag_sdk/
├── lib/
│   ├── src/
│   │   ├── core/          # Core models, interfaces, constants
│   │   ├── auth/          # Authentication providers and services
│   │   ├── subscription/  # Subscription providers and services
│   │   ├── analytics/     # Analytics and crashlytics services
│   │   └── ui/            # UI components
│   └── kharag_sdk.dart    # Main export file
├── test/                  # Tests
├── example/               # Example app
└── docs/                  # Additional documentation
```

## Pull Request Process

1. **Update documentation**: Ensure the README.md and other docs are updated
2. **Add tests**: All new features must include tests
3. **Follow coding standards**: Run `flutter analyze` and fix any issues
4. **Update CHANGELOG.md**: Add your changes under "Unreleased"
5. **Ensure tests pass**: Run `flutter test` and ensure all tests pass
6. **Update example app**: If adding features, update the example app
7. **Get review**: Wait for review from maintainers

### PR Title Format

Use conventional commit format:

- `feat: Add new authentication provider`
- `fix: Resolve subscription purchase issue`
- `docs: Update README with new examples`
- `test: Add unit tests for auth service`
- `refactor: Improve error handling`
- `chore: Update dependencies`

## Coding Standards

### General Guidelines

- **Follow Dart style guide**: Use `dart format` and `flutter analyze`
- **Use meaningful names**: Variables, functions, and classes should have descriptive names
- **Add comments**: Document public APIs and complex logic
- **Keep it simple**: Prefer simple, readable code over clever solutions
- **DRY principle**: Don't repeat yourself
- **Single responsibility**: Each class/function should do one thing well

### Code Style

```dart
// ✅ Good
class UserService {
  /// Fetches user data from the server
  ///
  /// Returns [Result<User>] with user data or failure
  Future<Result<User>> fetchUser(String userId) async {
    try {
      final user = await _api.getUser(userId);
      return Result.success(user);
    } catch (e) {
      return Result.failure(
        Failure.network(message: 'Failed to fetch user'),
      );
    }
  }
}

// ❌ Bad
class UserService {
  Future getUserData(String id) async {
    var data = await api.get(id);
    return data;
  }
}
```

### Architecture Principles

1. **Interface segregation**: Create interfaces for extensibility
2. **Dependency injection**: Use constructor injection
3. **Separation of concerns**: UI, domain, and data layers
4. **Error handling**: Use Result type for operations that can fail
5. **Immutability**: Prefer immutable data models (use Freezed)

### File Organization

- One class per file
- File names match class names (snake_case)
- Group related files in directories
- Export only what's needed

## Testing Guidelines

### Test Coverage

We aim for **>70% test coverage** on core logic.

### Types of Tests

1. **Unit Tests**: Test individual functions and classes
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test complete flows

### Writing Tests

```dart
// Example unit test
import 'package:flutter_test/flutter_test.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should register auth provider', () {
      final provider = MockGoogleAuthProvider();
      authService.registerProvider(provider);

      expect(
        authService.availableProviders,
        contains(AuthProviderType.google),
      );
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth/auth_service_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Documentation

### Code Documentation

- **Public APIs**: Must have dartdoc comments
- **Complex logic**: Add inline comments
- **Examples**: Include usage examples in dartdoc

```dart
/// Signs in the user with Google
///
/// Returns [Result<KharagUser>] containing the authenticated user
/// on success, or [Failure] on error.
///
/// Example:
/// ```dart
/// final result = await authService.signIn(AuthProviderType.google);
/// result.when(
///   success: (user) => print('Signed in: ${user.email}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
Future<Result<KharagUser>> signIn(AuthProviderType type);
```

### README Updates

When adding features:
1. Update the Features section
2. Add usage examples
3. Update the Table of Contents
4. Add troubleshooting tips if needed

## Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `style`: Code style changes (formatting)
- `chore`: Build process or auxiliary tool changes
- `perf`: Performance improvements

### Examples

```
feat(auth): add Apple Sign-In support

Implement Apple authentication provider following
the existing Google Sign-In pattern.

Closes #123
```

```
fix(subscription): handle cancelled purchases correctly

Previously, cancelled purchases threw an error.
Now they return a CancelledFailure result.

Fixes #456
```

## Getting Help

- **Questions**: Open a discussion on GitHub
- **Bugs**: Open an issue with the bug template
- **Features**: Open an issue with the feature template
- **Chat**: Join our community (link TBD)

## Recognition

Contributors will be:
- Added to CONTRIBUTORS.md
- Mentioned in release notes
- Credited in the README

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for contributing to Kharag SDK! 🎉
