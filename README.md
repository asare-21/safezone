# SafeZone 🚨

SafeZone is a **Waze-inspired, crowdsourced personal safety app** built with **Flutter**. It allows users to report safety incidents and automatically notifies others when they are **approaching areas with recent or frequent incidents**.

The goal of this project is to explore **real-time geospatial systems, proximity alerts, and trust-based reporting**, while building a practical, real-world mobile application suitable for a professional portfolio.

---

## ✨ Key Features

### 🧭 Real-Time Safety Alerts

* Automatically notifies users when they are near:

  * A recent safety incident
  * A high-risk area with repeated reports
* Alerts are triggered using **geofencing and proximity calculations**

### 📝 Crowdsourced Incident Reporting

* Report incidents in under 10 seconds
* Auto-captures GPS location and timestamp
* Supported incident categories:

  * Theft
  * Harassment
  * Assault
  * Suspicious activity
  * Unsafe environment
* Optional anonymous reporting

### 🗺️ Interactive Safety Map

* Map-based view of incidents
* Heatmap showing risk levels:

  * Green → Low risk
  * Yellow → Moderate risk
  * Red → High risk
* Filter incidents by:

  * Category
  * Time range (24h / 7d / 30d)

### ✅ Report Validation & Trust System

* Incidents gain confidence through:

  * Multiple reports in the same area
  * User confirmations ("Still an issue?")
* Basic user reputation score to reduce false reporting

### 🛣️ Route Safety Mode (Planned)

* Compare routes by:

  * Safety score
  * Distance
  * Time of day
* Suggests safer alternatives when available

---

## 🛠️ Tech Stack

### Frontend (Mobile)

* **Flutter (Dart)**
* Google Maps SDK or Mapbox
* Provider / Riverpod / Bloc (state management)

### Backend (Planned / Mocked for MVP)

* Python (FastAPI)
* PostgreSQL + PostGIS (geospatial queries)
* Redis (real-time proximity checks)
* Firebase / OneSignal (push notifications)

---

## 📐 System Design Overview

### Incident Risk Scoring (Simplified)

```dart
risk_score = incident_count × recency_weight × category_weight
```

### Proximity Alert Logic

* User location updates periodically
* Backend checks for incidents within a configurable radius
* Push notification triggered if risk threshold is exceeded

---

## 📱 App Screens (Planned)

* Home / Map View
* Report Incident Screen
* Incident Details
* Safety Alerts
* Settings & Privacy Controls

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Android Studio or Xcode
* Google Maps API key (or Mapbox token)

### Installation

```bash
git clone https://github.com/your-username/safezone.git
cd safezone
flutter pub get
flutter run
```

---

## 🔐 Privacy & Ethics

* No personally identifiable data is required
* Anonymous reporting supported
* Location data is only used for:

  * Incident reporting
  * Proximity alerts
* This project is **not affiliated with law enforcement or government agencies**

---

## 📈 Roadmap

* [ ] User authentication (optional)
* [ ] Advanced reputation scoring
* [ ] Route safety scoring
* [ ] Offline incident caching
* [ ] Admin dashboard for moderation

---

## 🎯 Why This Project

This project demonstrates:

* Mobile development with Flutter
* Geospatial data handling
* Real-time notifications
* Scalable backend design
* Ethical considerations in safety-focused applications

It is designed as a **portfolio project** showcasing practical engineering decisions rather than a production-ready public safety platform.

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙌 Acknowledgements

Inspired by community-driven navigation apps like **Waze**, adapted for **personal safety and situational awareness**.
