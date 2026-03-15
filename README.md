# 📸 EventFrame — Photographer Client Portal

A cross-platform client portal for photographers built with **Flutter** & **Supabase**. Securely deliver photo galleries to clients with QR code access, Google Drive integration, and in-app subscription management.

---

## 🛠️ Tech Stack

| Layer                | Technology                             |
| -------------------- | -------------------------------------- |
| **Frontend**         | Flutter (Web + Android + iOS)          |
| **Backend**          | Supabase (Auth + PostgreSQL + Storage) |
| **Storage**          | Supabase Storage + Google Drive        |
| **Subscriptions**    | RevenueCat                             |
| **State Management** | Riverpod                               |
| **Routing**          | go_router                              |
| **Auth**             | Supabase Auth + Google Sign-In         |

## 👥 User Roles

| Role                | Access                                                 |
| ------------------- | ------------------------------------------------------ |
| 🔴 **Admin**        | Platform management, user roles, membership plans      |
| 📷 **Photographer** | Studio, events, photo upload & delivery, subscriptions |
| 👤 **Client**       | Gallery viewer via event code or QR scan (always free) |

## ✨ Features

- 🔐 **Google Sign-In** & **Email Magic Link** authentication
- 📷 **Event management** — create events with unique access codes
- 🖼️ **Photo upload** to Supabase Storage with gallery view
- 📱 **QR code generation** for instant client access
- 💳 **In-app subscriptions** via RevenueCat (Android/iOS)
- 👥 **Admin dashboard** — manage users, roles, studios, memberships
- 🌙 **Dark/Light theme** with Material 3 design
- 🔒 **Row Level Security** on all database tables
- 🌐 **Cross-platform** — Web, Android, iOS

---

## 🚀 Getting Started

### 1. Supabase Setup

1. Create a project at [supabase.com](https://supabase.com)
2. Run the database schema in **SQL Editor**:
   ```sql
   -- Run supabase/schema.sql first, then supabase/rls_policies.sql
   ```
3. Enable **Google Auth** in Authentication → Providers
4. Create a **"photos"** storage bucket (public) in Storage
5. Add your dev URL to **Authentication → URL Configuration → Redirect URLs**:
   - `http://localhost`
   - `http://localhost:*`

### 2. Configure Credentials

Update `lib/app/config/supabase_config.dart` with your Supabase project URL and anon key.

Update `lib/app/services/revenue_cat_service.dart` with your RevenueCat API keys (mobile only).

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 📁 Project Structure

```
lib/
├── app/
│   ├── config/       # Supabase configuration
│   ├── providers/    # Auth & subscription providers (Riverpod)
│   ├── router/       # go_router (role-aware routing)
│   ├── services/     # RevenueCat service
│   └── theme/        # App theme (dark/light, Material 3)
├── features/
│   ├── auth/         # Login, role gate, AppUser model
│   ├── admin/        # 🔴 Admin portal (users, studios, plans)
│   ├── photographer/ # 📷 Photographer portal (events, photos, subscriptions)
│   └── client/       # 👤 Client gallery (code entry, photo viewer)
└── main.dart         # Entry point
```

```
supabase/
├── schema.sql        # PostgreSQL table definitions
└── rls_policies.sql  # Row Level Security policies
```

---

## 🗄️ Database Schema

| Table                | Description                          |
| -------------------- | ------------------------------------ |
| `profiles`           | User profiles linked to `auth.users` |
| `events`             | Photography events with access codes |
| `photos`             | Photo metadata + storage URLs        |
| `clients`            | Client event access tracking         |
| `orders`             | Photo purchase orders                |
| `memberships`        | Subscription plan definitions        |
| `pending_deliveries` | Drive delivery fallback              |

---

## 📜 License

This project is proprietary. All rights reserved.
