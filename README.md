# EventFrame — Photographer Client Portal

A cross-platform client portal for photographers built with Flutter.

## Tech Stack

- **Frontend**: Flutter (Web + Android + iOS)
- **Backend**: Firebase (Auth + Firestore + Functions + Storage)
- **Storage**: Google Drive (client-owned)
- **Payments**: Stripe
- **State**: Riverpod
- **Routing**: go_router

## Roles

| Role            | Access                         |
| --------------- | ------------------------------ |
| 🔴 Admin        | Platform management            |
| 📷 Photographer | Studio, events, photo delivery |
| 👤 Regular User | Gallery viewer (always free)   |

## Getting Started

### 1. Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (replaces firebase_options.dart)
flutterfire configure
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Project Structure

```
lib/
├── app/
│   ├── router/       # go_router (role-aware)
│   ├── theme/        # App theme (dark/light)
│   └── providers/    # Auth providers
├── features/
│   ├── auth/         # Login, role gate
│   ├── admin/        # 🔴 Admin portal
│   ├── photographer/ # 📷 Photographer portal
│   └── client/       # 👤 Client gallery
└── shared/           # Widgets, services, utils
```
