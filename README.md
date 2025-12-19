# SafeZone 🚨

[![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-02569B?logo=flutter)](https://flutter.dev)
[![Django](https://img.shields.io/badge/Django-4.2.23-092E20?logo=django)](https://www.djangoproject.com/)

SafeZone is a **Waze-inspired, crowdsourced personal safety app** that alerts users when they are approaching areas with recent or frequent safety incidents. Built with **Flutter** for mobile and **Django** for the backend, it combines community reporting, real-time proximity alerts, and an interactive safety map to help users make safer, more informed decisions while moving through their environment.

---

## 🎯 Project Vision

This project demonstrates practical engineering skills in mobile development, geospatial systems, and real-time notifications. It showcases:

- Mobile development with Flutter and state management (BLoC pattern)
- Geospatial data handling and mapping
- Real-time notifications with Firebase Cloud Messaging
- RESTful API design with Django
- Ethical considerations in safety-focused applications
- Comprehensive testing and documentation

**Note**: This is a **portfolio project** showcasing practical engineering decisions rather than a production-ready public safety platform.

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
- Incident confirmation system ("Confirm" action)
- Share incidents with others
- User reputation tracking
- Multiple reports increase incident confidence

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

### 4. Run the App

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
- ✅ **Local Storage**: Settings stored locally with SharedPreferences
- ✅ **User Control**: Granular privacy settings

### Ethical Considerations
- 🚫 **Not Affiliated**: Not affiliated with law enforcement or government agencies
- 🚫 **Not 911 Replacement**: Encourages proper emergency service usage
- ✅ **Community Driven**: Crowdsourced, community-validated data
- ✅ **Transparent**: Open-source codebase (portfolio project)
- ✅ **Moderation**: Basic trust system to reduce false reporting

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
- [x] Incident reporting with media upload
- [x] Firebase push notifications
- [x] Proximity-based alerts
- [x] User profile and settings
- [x] Emergency services directory
- [x] Notification preferences
- [x] Time-based filtering
- [x] Search functionality
- [x] Safe zones management

### Planned Features 🚧
- [ ] User authentication system
- [ ] Backend API integration
- [ ] Media upload for incident reports (camera/gallery)
- [ ] Advanced reputation scoring
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

This is a portfolio project, but contributions, suggestions, and feedback are welcome!

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
   - Follow existing code style
   - Add tests for new features
   - Update documentation
4. **Run tests and linting**
   ```bash
   # Frontend
   flutter test
   flutter analyze
   
   # Backend
   python manage.py test
   ```
5. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Code Style

- **Frontend**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- **Backend**: Follow [PEP 8](https://pep8.org/) style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

---

## 📚 Documentation

Additional documentation is available in the repository:

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

SafeZone is a **portfolio project** created for educational and demonstration purposes. It is **not intended for production use** as a public safety platform. Always contact proper emergency services (911, 999, etc.) in case of emergencies.

The app is provided "as is" without warranty of any kind. Use at your own risk.

---

<div align="center">
  <p><strong>Built to demonstrate modern mobile development practices and ethical technology design</strong></p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>
