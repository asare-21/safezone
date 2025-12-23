# Contributing to SafeZone 🤝

Thank you for your interest in contributing to SafeZone! We welcome contributions from developers of all skill levels.

## 🚀 Getting Started

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/safezone.git
cd safezone
```

### 2. Set Up Development Environment

**Backend:**
```bash
cd backend/safezone_backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install django==4.2.23 djangorestframework django-cors-headers
python manage.py migrate
```

**Frontend:**
```bash
cd frontend
flutter pub get
```

### 3. Run Tests

```bash
# Backend tests
cd backend/safezone_backend
python manage.py test

# Frontend tests
cd frontend
flutter test
flutter analyze
```

## 🔧 Development Workflow

1. **Create a branch** for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
   ```

2. **Make your changes** following our code style guidelines

3. **Write tests** for new functionality

4. **Run tests and linting**:
   ```bash
   # Frontend
   flutter test
   flutter analyze
   
   # Backend
   python manage.py test
   ```

5. **Commit your changes** with a clear message:
   ```bash
   git commit -m "Add: brief description of changes"
   ```

6. **Push and create a Pull Request**:
   ```bash
   git push origin your-branch-name
   ```

## 📝 Code Style

### Flutter/Dart
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `very_good_analysis` linting rules (already configured)
- Run `flutter analyze` before committing

### Python/Django
- Follow [PEP 8](https://pep8.org/) style guide
- Use meaningful variable and function names
- Add docstrings to functions and classes

## 🎯 Good First Issues

Looking for a place to start? Check out issues labeled [`good first issue`](https://github.com/asare-21/safezone/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22).

Current beginner-friendly tasks:
- **Pull-to-refresh** (#154) - Add swipe-to-refresh for incident lists
- **Analytics and insights** (#150) - Add basic analytics tracking
- **Multi-language support** (#147) - Help with internationalization

## 📋 Pull Request Guidelines

### Before Submitting

- [ ] Code follows the project's style guidelines
- [ ] Tests pass locally (`flutter test`, `python manage.py test`)
- [ ] Linting passes (`flutter analyze`)
- [ ] Documentation is updated if needed
- [ ] Commit messages are clear and descriptive

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
Describe how you tested your changes

## Related Issues
Closes #(issue number)
```

## 🐛 Reporting Bugs

When reporting bugs, please include:

1. **Description**: Clear description of the issue
2. **Steps to Reproduce**: How can we reproduce the bug?
3. **Expected Behavior**: What should happen?
4. **Actual Behavior**: What actually happens?
5. **Environment**: Flutter version, device/emulator, OS

## 💡 Suggesting Features

We love new ideas! When suggesting features:

1. Check existing issues to avoid duplicates
2. Describe the use case and benefit
3. Consider implementation complexity
4. Be open to discussion and feedback

## 🏗️ Architecture Notes

### Frontend (Flutter)
- Uses **BLoC pattern** for state management
- Cubits for lightweight state management
- Clean separation between UI, business logic, and data

### Backend (Django)
- **Django REST Framework** for APIs
- App-based modular structure
- PostgreSQL with PostGIS planned for production

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

## 💬 Getting Help

- Open an issue for questions
- Check existing documentation in `/docs`
- Review closed issues for similar problems

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing to SafeZone!** Your help makes communities safer. ❤️
