# SafeZone 🚨

[![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-02569B?logo=flutter)](https://flutter.dev)
[![Django](https://img.shields.io/badge/Django-4.2.23-092E20?logo=django)](https://www.djangoproject.com/)
[![GitHub Actions](https://github.com/asare-21/safezone/workflows/CodeQL/badge.svg)](https://github.com/asare-21/safezone/actions)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Good First Issues](https://img.shields.io/github/issues/asare-21/safezone/good%20first%20issue?color=7057ff&label=good%20first%20issues)](https://github.com/asare-21/safezone/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)

SafeZone is a **Waze-inspired, crowdsourced personal safety app** that alerts users when they are approaching areas with recent or frequent safety incidents. Built with **Flutter** for mobile and **Django** for the backend, it combines community reporting, real-time proximity alerts, and an interactive safety map to help users make safer, more informed decisions while moving through their environment.

---

## 📊 Project Status

> ⚠️ **Early Development** - This project is under active development. Core features are functional, but some features are still being built.

| Component | Status | Description |
|-----------|--------|-------------|
| 🗺️ Interactive Map | ✅ Working | View incidents on map with filters |
| 📝 Incident Reporting | ✅ Working | Report incidents with 18 categories |
| 🔔 Push Notifications | ✅ Working | Firebase Cloud Messaging integration |
| 👤 User Authentication | ✅ Working | Auth0 integration with JWT tokens |
| 🔧 Django Backend API | ✅ Working | REST API with incident CRUD |
| ✅ Report Validation | ✅ Working | Confirmation prompts with scoring |
| 📷 Media Upload | 🚧 Planned | Camera/gallery support for reports |
| 🌡️ Heatmap View | 🚧 Planned | Density visualization |
| 🌙 Dark Mode | 🚧 Planned | Theme support |

---

## 🎯 Project Vision

SafeZone is an **open-source community project** that aims to make neighborhoods safer through crowdsourced incident reporting and real-time alerts. We're actively seeking contributors to help build and improve this platform!

**We're looking for contributors in:**
- 📱 Mobile development (Flutter/Dart)
- 🐍 Backend development (Django/Python)
- 🗺️ Geospatial systems and mapping
- 🔔 Real-time notifications (Firebase)
- 🧪 Testing and quality assurance
- 📖 Documentation and tutorials
- 🎨 UI/UX design
- 🌍 Internationalization and localization

---

## ⚡ Quick Start (10 Minutes)

Get SafeZone running locally in just a few steps:

### Backend (Terminal 1)

```bash
# Clone and navigate to backend
git clone https://github.com/asare-21/safezone.git
cd safezone/backend/safezone_backend

# Install dependencies
pip install django==4.2.23 djangorestframework django-cors-headers

# Setup database and start server
python manage.py migrate
python manage.py populate_guides
python manage.py populate_emergency_services
python manage.py runserver 8000
```

✅ API running at `http://localhost:8000/api/incidents/`

### Frontend (Terminal 2)

```bash
cd safezone/frontend
flutter pub get
flutter run -t lib/main_development.dart
```

✅ App connects to backend and displays incidents!

### Test the API

```bash
# List all incidents
curl http://localhost:8000/api/incidents/

# Create a test incident
curl -X POST http://localhost:8000/api/incidents/ \
  -H "Content-Type: application/json" \
  -d '{"category": "theft", "latitude": 5.6037, "longitude": -0.1870, "title": "Test", "description": "Testing API"}'
```

📖 **Full setup guide:** [docs/QUICK_START.md](docs/QUICK_START.md)

---

## ✨ Key Features

### 🧭 Real-Time Safety Alerts
- Automatically notifies users when approaching areas with recent safety incidents
- Geofencing and proximity-based alerts
- Customizable alert radius (0.5-10km)
- Firebase Cloud Messaging integration for push notifications

### 📝 Crowdsourced Incident Reporting
- Quick incident reporting in under 30 seconds
- Auto-captures GPS location and timestamp
- 18 comprehensive incident categories:
  - 🏃 Theft
  - 💥 Assault  
  - 😟 Harassment
  - 🚗 Accident
  - 🔥 Fire
  - 🔍 Suspicious Activity
  - 💡 Lighting Issue
  - 🔨 Vandalism
  - ⚠️ Road Hazard
  - 🐾 Animal Danger
  - 🏥 Medical Emergency
  - 🌪️ Natural Disaster
  - ⚡ Power Outage
  - 💧 Water Issue
  - 🔊 Noise Complaint
  - 🚫 Trespassing
  - 💊 Drug Activity
  - 🔫 Weapon Sighting
- Optional anonymous reporting
- Notify nearby users feature

### 🗺️ Interactive Safety Map
- Real-time map view of reported incidents
- Color-coded incident markers by category
- Pulse animation for recent incidents (<1 hour old)
- Filter incidents by:
  - Category
  - Time range (24h / 7d / 30d)
  - Search (by title/description)
- Zoom controls and location centering
- Incident details with map preview
- Empty state handling with filter clearing

### ✅ Report Validation & Trust System
- **Incident confirmation prompts**: Automatically prompts users when they approach reported incidents to confirm if still present
- **Smart proximity detection**: Monitors user location and detects nearby incidents within 500m
- **Points-based scoring**: Earn 5 points for each incident confirmation
- **Duplicate prevention**: Only prompted once per incident per user
- **User reputation tracking**: Build trust score through accurate confirmations
- **Tier progression**: Advance through 7 tier levels (Fresh Eye Scout → Legendary Watchmaster)
- **Achievement badges**: Earn special badges (Truth Triangulator, First Responder, etc.)
- Multiple confirmations increase incident confidence

### 🔔 Notification Settings
- Granular notification controls
- Push notification toggle
- Proximity alert preferences
- Sound and vibration settings
- Anonymous reporting option
- Location sharing preferences
- Persistent settings with SharedPreferences

### 🆘 Emergency Services
- Quick access to emergency contacts
- Emergency services directory
- One-tap emergency calling

### 👤 User Profile & History
- Incident reporting history
- User settings management
- Safe zones configuration
- Profile customization

---

## 📸 Screenshots

> 🖼️ **Coming Soon!** We're working on adding app screenshots and demo GIFs.
> 
> **Want to help?** If you have the app running, consider contributing screenshots! See our [Contributing Guide](CONTRIBUTING.md).

<!-- 
Uncomment and add screenshots when available:
| Map View | Report Incident | Alerts |
|----------|-----------------|--------|
| ![Map](screenshots/map.png) | ![Report](screenshots/report.png) | ![Alerts](screenshots/alerts.png) |
-->

---

## 🏗️ Architecture Overview

SafeZone follows a **clean architecture** approach with clear separation between frontend and backend:

```
safezone/
├── frontend/          # Flutter mobile application
│   ├── lib/
│   │   ├── alerts/            # Alert management and filtering
│   │   ├── app/               # App configuration and routing
│   │   ├── authentication/    # User authentication screens
│   │   ├── emergency_services/# Emergency contacts feature
│   │   ├── guide/             # Onboarding and tutorials
│   │   ├── home/              # Home screen with navigation
│   │   ├── incident_report/   # Incident reporting UI
│   │   ├── map/               # Interactive map with incidents
│   │   ├── profile/           # User profile and settings
│   │   ├── utils/             # Shared utilities and routing
│   │   └── l10n/              # Internationalization
│   ├── test/                  # Comprehensive unit & widget tests
│   ├── assets/                # Images and icons
│   └── pubspec.yaml           # Flutter dependencies
│
└── backend/           # Django REST API
    └── safezone_backend/
        ├── alerts/            # Alert system models and views
        ├── authentication/    # User authentication
        ├── guides/            # Help and guide content
        ├── incident_reporting/# Incident CRUD operations
        ├── push_notifications/# FCM notification service
        └── user_settings/     # User preferences management
```

### Frontend Architecture (Flutter)

The frontend uses the **BLoC (Business Logic Component)** pattern for state management:

- **Cubits**: Lightweight state management for features
  - `MapFilterCubit` - Manages map filters and search
  - `AlertFilterCubit` - Handles alert filtering
  - `NotificationSettingsCubit` - Notification preferences
  - `ProfileCubit` - User profile state
  - `SafeZoneCubit` - Safe zone management
  - `BottomNavigationCubit` - App navigation

- **Models**: Immutable data classes with Equatable
  - `Incident` - Incident data model
  - `Alert` - Alert data model
  - `EmergencyService` - Emergency contact model

- **Repositories**: Data layer abstraction
  - `ProfileSettingsRepository` - Profile data persistence
  - `SafeZoneRepository` - Safe zone data management
  - `EmergencyServicesRepository` - Emergency services data

- **Views**: Stateless widgets with BlocBuilder/BlocProvider

### Backend Architecture (Django)

- **Django 4.2.23** with REST framework
- App-based modular structure
- PostgreSQL with PostGIS for geospatial queries (planned)
- Firebase Admin SDK for push notifications

---

## 🛠️ Tech Stack

### Frontend (Mobile)
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.8.0+ | Cross-platform mobile framework |
| **Dart SDK** | 3.8.0+ | Programming language |
| **flutter_bloc** | 9.1.1 | State management |
| **flutter_map** | 7.0.2 | Interactive maps |
| **go_router** | 17.0.1 | Navigation and routing |
| **geolocator** | ^13.0.2 | GPS and location services |
| **geocoding** | ^3.0.0 | Address geocoding |
| **firebase_core** | ^3.10.0 | Firebase SDK |
| **firebase_messaging** | ^15.1.6 | Push notifications |
| **shared_preferences** | ^2.3.4 | Local data persistence |
| **shadcn_ui** | ^0.42.0 | UI component library |
| **equatable** | ^2.0.7 | Value equality |
| **intl** | ^0.20.2 | Internationalization |
| **introduction_screen** | ^4.0.0 | Onboarding screens |
| **latlong2** | ^0.9.1 | Latitude/longitude handling |
| **line_icons** | ^2.0.3 | Icon library |
| **url_launcher** | ^6.3.1 | URL and phone launching |
| **dots_indicator** | ^4.0.1 | Page indicators |
| **bloc_test** | ^10.0.0 | BLoC testing utilities |
| **mocktail** | ^1.0.4 | Mocking for tests |
| **very_good_analysis** | ^9.0.0 | Linting rules |

### Backend (API Server)
| Technology | Version | Purpose |
|------------|---------|---------|
| **Django** | 4.2.23 | Web framework |
| **Python** | 3.x | Programming language |
| **PostgreSQL** | Latest | Database (planned) |
| **PostGIS** | Latest | Geospatial extension (planned) |
| **Redis** | Latest | Caching and proximity checks (planned) |
| **Firebase Admin** | Latest | Push notification delivery (planned) |

---

## 📁 Repository Structure

```
.
├── backend/
│   └── safezone_backend/        # Django project
│       ├── alerts/              # Alert management
│       ├── authentication/      # User auth
│       ├── incident_reporting/  # Incident APIs
│       ├── push_notifications/  # FCM integration
│       ├── user_settings/       # User preferences
│       ├── guides/              # Help content
│       └── safezone_backend/    # Django settings
│
├── frontend/                    # Flutter application
│   ├── android/                 # Android platform code
│   ├── ios/                     # iOS platform code
│   ├── assets/                  # Images, icons
│   ├── lib/                     # Dart source code
│   ├── test/                    # Unit and widget tests
│   ├── pubspec.yaml             # Dependencies
│   └── *.md                     # Feature documentation
│
└── README.md                    # This file
```

---

## 🚀 Getting Started

### Prerequisites

#### Frontend Development
- **Flutter SDK** 3.8.0 or higher
- **Dart SDK** 3.8.0 or higher
- **Android Studio** or **Xcode** (for iOS)
- **Visual Studio Code** (recommended) with Flutter extension
- **Google Maps API key** or **Mapbox token**
- **Firebase project** (for push notifications)

#### Backend Development
- **Python** 3.8 or higher
- **Django** 4.2.23
- **PostgreSQL** with PostGIS extension (optional for MVP)
- **Redis** (optional for caching)

---

## 📱 Frontend Setup

### 1. Clone the Repository

```bash
git clone https://github.com/asare-21/safezone.git
cd safezone/frontend
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

#### Option A: FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### Option B: Manual Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android app:
   - Download `google-services.json`
   - Place in `frontend/android/app/`
3. Add iOS app:
   - Download `GoogleService-Info.plist`
   - Place in `frontend/ios/Runner/`

See `frontend/NOTIFICATION_SETTINGS.md` for detailed Firebase setup instructions.

### 4. Auth0 Configuration

SafeZone uses Auth0 for user authentication. You can pass Auth0 credentials to the frontend application using one of the following methods:

#### Option A: Environment Variables at Build Time (Recommended for CI/CD)

Pass Auth0 credentials using `--dart-define` flags when building or running the app:

```bash
flutter run --dart-define=AUTH0_DOMAIN=your-tenant.auth0.com \
            --dart-define=AUTH0_CLIENT_ID=your-client-id \
            --dart-define=AUTH0_AUDIENCE=https://safezone-api
```

For production builds:

```bash
flutter build apk --dart-define=AUTH0_DOMAIN=your-tenant.auth0.com \
                  --dart-define=AUTH0_CLIENT_ID=your-client-id \
                  --dart-define=AUTH0_AUDIENCE=https://safezone-api

flutter build ios --dart-define=AUTH0_DOMAIN=your-tenant.auth0.com \
                  --dart-define=AUTH0_CLIENT_ID=your-client-id \
                  --dart-define=AUTH0_AUDIENCE=https://safezone-api
```

#### Option B: Direct Configuration (Development Only)

For local development, you can update the configuration file directly:

Edit `frontend/lib/authentication/config/auth0_config.dart`:

```dart
class Auth0Config {
  const Auth0Config._();

  static const String domain = 'your-tenant.auth0.com';
  static const String clientId = 'your-client-id-from-auth0';
  static const String audience = 'https://safezone-api';

  static const List<String> scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];
}
```

> ⚠️ **Security Note**: Never commit actual Auth0 credentials to version control. Use environment variables or secrets management for production deployments.

#### Auth0 Setup Requirements

1. Create an Auth0 account at [auth0.com](https://auth0.com)
2. Create a **Native** application in the Auth0 dashboard
3. Configure callback URLs:
   - `com.safezone.app://YOUR_AUTH0_DOMAIN/ios/com.safezone.app/callback`
   - `com.safezone.app://YOUR_AUTH0_DOMAIN/android/com.safezone.app/callback`
4. Create an API in Auth0 for the backend

See `docs/AUTH0_INTEGRATION.md` for complete Auth0 setup instructions.

### 5. Run the App

```bash
# Development build
flutter run -t lib/main_development.dart

# Staging build
flutter run -t lib/main_staging.dart

# Production build
flutter run -t lib/main_production.dart
```

### 5. Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/map/cubit/map_filter_cubit_test.dart
```

---

## 🔧 Backend Setup

### 1. Navigate to Backend Directory

```bash
cd safezone/backend/safezone_backend
```

### 2. Create Virtual Environment

```bash
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install django==4.2.23
# Additional dependencies as needed
```

### 4. Database Setup

```bash
python manage.py migrate

# Populate initial data
python manage.py populate_guides
python manage.py populate_emergency_services
```

### 5. Create Superuser (Optional)

```bash
python manage.py createsuperuser
```

### 6. Run Development Server

```bash
python manage.py runserver
```

The API will be available at `http://localhost:8000/`

### 7. Run Tests

```bash
python manage.py test
```

---

## 🧪 Testing

### Frontend Testing

The frontend includes comprehensive test coverage:

- **Unit Tests**: Cubit logic, models, utilities
- **Widget Tests**: UI components, screens
- **Integration Tests**: User flows (planned)

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage
lcov --list coverage/lcov.info

# Run specific test suite
flutter test test/profile/cubit/
```

**Test Coverage Highlights:**
- Notification settings: 275+ lines of tests
- Map filtering: Comprehensive cubit tests
- Incident model: 20+ test cases
- Report incident screen: 18+ widget tests

### Backend Testing

```bash
python manage.py test
```

---

## 📐 System Design

### Incident Risk Scoring

```python
risk_score = incident_count × recency_weight × category_weight
```

**Recency Weights:**
- < 1 hour: 1.0 (highest priority)
- < 24 hours: 0.8
- < 7 days: 0.5
- < 30 days: 0.2

**Category Weights:**
- Assault: 1.0
- Theft: 0.8
- Harassment: 0.7
- Suspicious Activity: 0.5
- Poor Lighting: 0.3
- Accident: 0.6

### Proximity Alert Logic

1. User location updates periodically (background service)
2. Backend checks for incidents within configurable radius
3. Risk score calculated for nearby incidents
4. Push notification triggered if risk threshold exceeded
5. Notification includes incident category, distance, and time

### Data Flow

```
User Report → Frontend Validation → Backend API → Database Storage
                                          ↓
                                    Geospatial Query
                                          ↓
                              Identify Nearby Users
                                          ↓
                                  Firebase FCM Topic
                                          ↓
                              Push Notification Delivery
```

---

## 📱 App Screens

### 1. **Authentication Screen**
- User login/signup
- Anonymous mode option
- Profile creation

### 2. **Home Screen**
- Bottom navigation (Map, Alerts, Profile)
- Quick access to emergency services
- Recent activity overview

### 3. **Map Screen**
- Interactive map with incident markers
- Category-based color coding
- Time filter (24h/7d/30d)
- Search functionality
- Zoom and location controls
- Incident details bottom sheet

### 4. **Report Incident Screen**
- Category selection (18 comprehensive categories)
- Title and description fields
- Auto-location capture
- Notify nearby users toggle
- Quick submission
- Media upload support (planned)

### 5. **Alerts Screen**
- List of active proximity alerts
- Filter by time and category
- Alert details with map location
- Confirmation and sharing actions

### 6. **Profile Screen**
- User incident history
- Notification settings
- Safe zones management
- App preferences
- Emergency contacts

### 7. **Emergency Services Screen**
- Quick access to emergency numbers
- Contact directory
- One-tap calling

---

## 🔐 Privacy & Ethics

SafeZone is designed with privacy and ethical considerations at its core:

### Privacy Principles
- ✅ **No PII Required**: Anonymous reporting supported
- ✅ **Location Privacy**: Location data only used for incident reporting and alerts
- ✅ **Data Minimization**: Only essential data collected
- ✅ **Strong Encryption**: AES-256 encryption for sensitive data at rest, TLS 1.2+ for data in transit
- ✅ **Local Storage**: Settings stored locally with SharedPreferences
- ✅ **User Control**: Granular privacy settings
- ✅ **GDPR/CCPA Compliant**: Full compliance with international privacy regulations

### Ethical Considerations
- 🚫 **Not Affiliated**: Not affiliated with law enforcement or government agencies
- 🚫 **Not 911 Replacement**: Encourages proper emergency service usage
- ✅ **Community Driven**: Crowdsourced, community-validated data
- ✅ **Transparent**: Fully open-source, community-driven development
- ✅ **Moderation**: Basic trust system to reduce false reporting

### Security & Encryption
- ✅ **Field-Level Encryption**: Device IDs and FCM tokens encrypted in database (AES-256)
- ✅ **HTTPS/TLS**: All API communications encrypted in transit (TLS 1.2+)
- ✅ **Security Headers**: HSTS, CSP, X-Frame-Options, XSS protection
- ✅ **Data Retention**: Automatic cleanup of expired data (90 days for incidents)
- ✅ **User Rights**: Full data export and deletion capabilities

### Data Stored
- Incident location (GPS coordinates)
- Incident category and description
- Timestamp
- Optional: User ID (for reputation)

### Data NOT Stored
- Real names (unless voluntarily provided)
- Personal contact information
- Detailed movement patterns
- Private messages

---

## 📈 Roadmap

### Current Status ✅
- [x] Interactive map with incident markers
- [x] Incident reporting (18 categories)
- [x] Firebase push notifications
- [x] Proximity-based alerts
- [x] Incident confirmation prompts with scoring
- [x] Automatic proximity detection for nearby incidents
- [x] Points-based reward system with tier progression
- [x] User profile and settings
- [x] Emergency services directory
- [x] Notification preferences
- [x] Time-based filtering
- [x] Search functionality
- [x] Safe zones management
- [x] Auth0 user authentication system
- [x] Django REST backend API integration
- [x] Secure JWT token-based authentication

### Planned Features 🚧
- [ ] Media upload for incident reports (camera/gallery)
- [ ] Push notifications for incident proximity
- [ ] Route safety scoring
- [ ] Offline incident caching
- [ ] Admin moderation dashboard
- [ ] Heatmap visualization
- [ ] Marker clustering
- [ ] Pull-to-refresh
- [ ] Tutorial overlay
- [ ] Analytics and insights
- [ ] Multi-language support
- [ ] Dark mode themes

---

## 🤝 Contributing

**We welcome contributions from developers of all skill levels!** Whether you're fixing a bug, adding a feature, improving documentation, or suggesting ideas—your contributions are valuable and appreciated.

📖 **See our [Contributing Guide](CONTRIBUTING.md) for detailed instructions.**

### 🎯 Good First Issues

New to the project? Start with these beginner-friendly issues:

- **[Pull-to-refresh](https://github.com/asare-21/safezone/issues/154)** - Add swipe-to-refresh for lists
- **[Multi-language support](https://github.com/asare-21/safezone/issues/147)** - Help with i18n
- **[Analytics and insights](https://github.com/asare-21/safezone/issues/150)** - Basic analytics

👉 **[View all good first issues](https://github.com/asare-21/safezone/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)**

### Quick Start for Contributors

```bash
# Fork, clone, and setup
git clone https://github.com/YOUR_USERNAME/safezone.git
cd safezone/frontend && flutter pub get && flutter test
```

### Code Style

- **Frontend**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- **Backend**: Follow [PEP 8](https://pep8.org/) style guide

---

## 📚 Documentation

Additional documentation is available in the repository:

### Authentication & Integration
- **[AUTH0_INTEGRATION.md](docs/AUTH0_INTEGRATION.md)** - Complete Auth0 setup guide for backend and frontend
- **[AUTH0_IMPLEMENTATION_SUMMARY.md](docs/AUTH0_IMPLEMENTATION_SUMMARY.md)** - Auth0 integration implementation details
- **[BACKEND_INTEGRATION.md](docs/BACKEND_INTEGRATION.md)** - Backend API integration guide
- **[QUICK_START.md](docs/QUICK_START.md)** - Quick start guide for backend/frontend setup

### Security & Privacy
- **[PRIVACY_POLICY.md](docs/PRIVACY_POLICY.md)** - Complete privacy policy with GDPR/CCPA compliance
- **[DATA_ENCRYPTION.md](docs/DATA_ENCRYPTION.md)** - Detailed encryption and security measures
- **[SECURITY_GUIDE.md](docs/SECURITY_GUIDE.md)** - Developer guide for security implementation
- **[IMPLEMENTATION_SUMMARY.md](docs/IMPLEMENTATION_SUMMARY.md)** - Security and privacy implementation summary

### Feature Documentation
- **[INCIDENT_CONFIRMATION_FEATURE.md](docs/INCIDENT_CONFIRMATION_FEATURE.md)** - Incident confirmation prompts and scoring system
- **[SCORING_SYSTEM_GUIDE.md](docs/SCORING_SYSTEM_GUIDE.md)** - Truth Hunter scoring system implementation guide
- **[IMPLEMENTATION_SUMMARY.md](frontend/IMPLEMENTATION_SUMMARY.md)** - Notification settings implementation
- **[NOTIFICATION_SETTINGS.md](frontend/NOTIFICATION_SETTINGS.md)** - Firebase configuration guide
- **[MAP_UI_FINAL_SUMMARY.md](frontend/MAP_UI_FINAL_SUMMARY.md)** - Map UI improvements
- **[INCIDENT_REPORTING_IMPLEMENTATION.md](frontend/INCIDENT_REPORTING_IMPLEMENTATION.md)** - Incident reporting features (includes planned media upload)
- **[VISUAL_CHANGES.md](frontend/VISUAL_CHANGES.md)** - UI/UX improvements
- **[CATEGORY_BASED_REPORTING_SUMMARY.md](frontend/CATEGORY_BASED_REPORTING_SUMMARY.md)** - Category system
- **[GEOFENCING_IMPLEMENTATION.md](frontend/GEOFENCING_IMPLEMENTATION.md)** - Geofencing details

---

## 📄 License

This project is open source and available for educational purposes. See individual file headers for specific licensing information.

---

## 🙌 Acknowledgements

- **Inspired by**: Community-driven navigation apps like [Waze](https://www.waze.com/)
- **Adapted for**: Personal safety and situational awareness
- **Built with**: Flutter, Django, Firebase, and love ❤️

---

## 📧 Contact

**Repository Owner**: [asare-21](https://github.com/asare-21)

**Repository**: [https://github.com/asare-21/safezone](https://github.com/asare-21/safezone)

---

## ⚠️ Disclaimer

SafeZone is an **open-source community project** under active development. While we strive for reliability and safety, always contact proper emergency services (911, 999, etc.) in case of emergencies.

The app is provided "as is" without warranty of any kind. Use at your own risk.

---

<div align="center">
  <p><strong>Built with ❤️ by the community, for the community</strong></p>
  <p>⭐ Star this repo if you find it helpful!</p>
  <p>🤝 <a href="#-contributing">Contributions welcome!</a></p>
</div>
