# Contributing to GivingBridge

Thank you for your interest in contributing to GivingBridge! This document provides guidelines and information for contributors.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Documentation](#documentation)
- [Security](#security)

## Code of Conduct

### Our Pledge
We are committed to making participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards
Examples of behavior that contributes to creating a positive environment include:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

### Unacceptable Behavior
Examples of unacceptable behavior include:
- The use of sexualized language or imagery and unwelcome sexual attention or advances
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate in a professional setting

## Getting Started

### Prerequisites
Before contributing, ensure you have:
- Read the [Development Setup Guide](backend/DEVELOPMENT_SETUP.md)
- Set up your development environment
- Familiarized yourself with the codebase structure
- Joined our developer communication channels

### First Contribution
1. Look for issues labeled `good first issue` or `help wanted`
2. Comment on the issue to express interest
3. Wait for maintainer assignment before starting work
4. Follow the development process outlined below

## Development Process

### 1. Fork and Clone
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/givingbridge.git
cd givingbridge

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/givingbridge.git
```

### 2. Create Feature Branch
```bash
# Update your fork
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name
```

### 3. Branch Naming Convention
- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Critical fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test improvements

### 4. Make Changes
- Follow coding standards (see below)
- Write tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 5. Commit Guidelines
We follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format: type(scope): description
git commit -m "feat(auth): add password reset functionality"
git commit -m "fix(api): resolve user registration validation"
git commit -m "docs(readme): update installation instructions"
```

#### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes

### 6. Push and Create PR
```bash
git push origin feature/your-feature-name
# Create pull request on GitHub
```

## Coding Standards

### JavaScript/Node.js (Backend)

#### Code Style
- Use ESLint and Prettier configurations
- 2 spaces for indentation
- Semicolons required
- Single quotes for strings
- Trailing commas in multiline structures

#### Example:
```javascript
const express = require('express');
const { body, validationResult } = require('express-validator');

const createUser = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const user = await UserService.create(req.body);
    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: { user },
    });
  } catch (error) {
    next(error);
  }
};
```

#### Naming Conventions
- `camelCase` for variables and functions
- `PascalCase` for classes and constructors
- `UPPER_SNAKE_CASE` for constants
- Descriptive names over short names

#### File Structure
```
src/
├── controllers/     # Route handlers
├── services/        # Business logic
├── models/          # Database models
├── middleware/      # Express middleware
├── utils/           # Utility functions
├── config/          # Configuration files
└── routes/          # Route definitions
```

### Dart/Flutter (Frontend)

#### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` for formatting
- 2 spaces for indentation
- `lowerCamelCase` for variables and functions
- `UpperCamelCase` for classes

#### Example:
```dart
class UserService {
  static const String _baseUrl = 'http://localhost:3000/api';

  Future<User> createUser(CreateUserRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        throw ApiException('Failed to create user');
      }
    } catch (e) {
      throw ServiceException('User creation failed: $e');
    }
  }
}
```

### Database

#### Migration Guidelines
- Always create reversible migrations
- Use descriptive migration names
- Include proper indexes
- Handle data migration carefully

#### Example Migration:
```javascript
// 025_add_user_preferences_table.js
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('user_preferences', {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      userId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      emailNotifications: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
    });

    await queryInterface.addIndex('user_preferences', ['userId']);
  },

  down: async (queryInterface) => {
    await queryInterface.dropTable('user_preferences');
  },
};
```

## Testing Guidelines

### Backend Testing

#### Unit Tests
- Test individual functions and methods
- Mock external dependencies
- Aim for 80%+ code coverage
- Use descriptive test names

```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'securePassword123',
      };

      const user = await UserService.create(userData);

      expect(user).toBeDefined();
      expect(user.email).toBe(userData.email);
      expect(user.password).not.toBe(userData.password); // Should be hashed
    });

    it('should throw error with invalid email', async () => {
      const userData = {
        name: 'John Doe',
        email: 'invalid-email',
        password: 'securePassword123',
      };

      await expect(UserService.create(userData)).rejects.toThrow('Invalid email format');
    });
  });
});
```

#### Integration Tests
- Test API endpoints end-to-end
- Use test database
- Clean up after each test

```javascript
describe('POST /api/users', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  it('should create user successfully', async () => {
    const userData = {
      name: 'John Doe',
      email: 'john@example.com',
      password: 'securePassword123',
    };

    const response = await request(app)
      .post('/api/users')
      .send(userData)
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.data.user.email).toBe(userData.email);
  });
});
```

### Frontend Testing

#### Widget Tests
```dart
testWidgets('UserCard displays user information', (WidgetTester tester) async {
  final user = User(
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
  );

  await tester.pumpWidget(
    MaterialApp(
      home: UserCard(user: user),
    ),
  );

  expect(find.text('John Doe'), findsOneWidget);
  expect(find.text('john@example.com'), findsOneWidget);
});
```

#### Integration Tests
```dart
void main() {
  group('User Registration Flow', () {
    testWidgets('should register user successfully', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Navigate to registration
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byKey(Key('name_field')), 'John Doe');
      await tester.enterText(find.byKey(Key('email_field')), 'john@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');

      // Submit form
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Registration successful'), findsOneWidget);
    });
  });
}
```

## Pull Request Process

### Before Submitting
- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] New tests added for new functionality
- [ ] Documentation updated
- [ ] No merge conflicts with main branch
- [ ] Commit messages follow convention

### PR Template
When creating a pull request, include:

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
```

### Review Process
1. Automated checks must pass (CI/CD)
2. At least one maintainer review required
3. Address all review comments
4. Maintain clean commit history
5. Squash commits if requested

## Issue Reporting

### Bug Reports
Use the bug report template:

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
- OS: [e.g. iOS]
- Browser [e.g. chrome, safari]
- Version [e.g. 22]

**Additional context**
Add any other context about the problem here.
```

### Feature Requests
Use the feature request template:

```markdown
**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is.

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

## Documentation

### Code Documentation
- Use JSDoc for JavaScript functions
- Use Dart doc comments for Dart code
- Document complex algorithms and business logic
- Keep README files updated

### API Documentation
- Update Swagger/OpenAPI specs for API changes
- Include request/response examples
- Document error codes and responses
- Provide usage examples

### User Documentation
- Update user guides for UI changes
- Include screenshots for new features
- Maintain FAQ and troubleshooting guides

## Security

### Reporting Security Issues
- **DO NOT** create public issues for security vulnerabilities
- Email security@givingbridge.com with details
- Include steps to reproduce
- Allow time for fix before public disclosure

### Security Guidelines
- Never commit secrets or credentials
- Use environment variables for configuration
- Validate all user inputs
- Follow OWASP security guidelines
- Keep dependencies updated

## Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes for significant contributions
- Annual contributor appreciation posts

## Questions?

- Check existing documentation first
- Search closed issues and PRs
- Join our developer Discord/Slack
- Email dev@givingbridge.com

Thank you for contributing to GivingBridge! 🙏