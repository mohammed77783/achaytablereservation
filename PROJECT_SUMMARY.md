# Achay Table Reservation - Project Structure Summary

## Overview
A **Flutter table reservation app** (TeaBake/Achay) for restaurants in Saudi Arabia. Built with **GetX** for state management, dependency injection, and routing. Supports **Arabic (RTL) & English** localization. Uses **Moyasar** for payments and **Sentry** for crash reporting.

**Version:** 1.0.7+10 | **SDK:** ^3.10.3

---

## Architecture Pattern
**Feature-First Clean Architecture** with GetX:
```
lib/
├── app/            → App-level config (routes, themes, translations, bindings)
├── core/           → Shared core (network, storage, services, models, errors)
├── features/       → Feature modules (each with data/logic/ui layers)
└── main.dart       → Entry point
```

---

## App Flow
```
main.dart → initializeApp() → SplashScreen (5s)
   ├── Authenticated? → MainNavigationScaffold (Home | Bookings | Notifications | More)
   └── Not Authenticated? → LoginPage
```

---

## Features Breakdown

### 1. Authentication (`features/authentication/`)
- **Screens:** Login, Sign Up, OTP Verification, Forgot Password, Reset Password
- **Flow:** Phone + Password → OTP verification → JWT tokens (access + refresh)
- **Controllers:** `LoginController`, `SignInController`, `OtpController`, `ForgotPasswordController`, `ResetPasswordController`
- **State:** `AuthStateController` (permanent, global) — manages auth state across the entire app
- **Repository:** `AuthRepository` — handles token storage, refresh logic with retry, data persistence
- **Data Source:** `AuthDataSource` — API calls for auth endpoints
- **Token Management:** Access token + Refresh token with automatic refresh, expiration tracking, 401 interceptor

### 2. Homepage (`features/homepage/`)
- **Screens:** Homepage (branch listing), Branch Info Page, Media Viewer
- **Controller:** `HomeController` — loads user data + branches, location-based sorting
- **Widgets:** ProfileHeader (user greeting), BranchCard, LocationSelector, BusinessHours
- **Data:** Branch models with gallery photos, business hours, city coordinates for distance calculation

### 3. Reservation (`features/reservation/`)
- **Screens:** Reservation Page (calendar + time slots), Reservation Confirmation, Booking Details, Bookings List
- **Controller:** `ReservationController` — calendar selection, time slot fetching, guest count, price calculation (tier-based: 1-4→4, 5-8→8, 9-12→12 seats), table availability check
- **Controller:** `BookingsController` — user's reservation list
- **Controller:** `ReservationConfirmationController` — confirm reservation
- **Models:** RestaurantAvailabilityResponse, TimeSlot, Hall, CalendarDay, AvailableTable, Policy
- **Flow:** Select Date → Select Time Slot → Set Guest Count → Check Availability → Confirm → Payment

### 4. Payment (`features/payment/`)
- **Screen:** Payment Page
- **Service:** Moyasar payment service (credit card + Apple Pay)
- **Widgets:** HorizontalCardWidget, ApplePayButton, 3DS WebView

### 5. Profile (`features/profile/`)
- **Screens:** Profile Screen, Update Profile, Update Password, Change Phone
- **Controller:** `ProfileController`, `UpdateProfileController`, `UpdatePasswordController`, `ChangePhoneController`
- **Data Source:** `ProfileDataSource` — profile API calls

### 6. Navigation (`features/navigation/`)
- **Scaffold:** `MainNavigationScaffold` with BottomNavigationBar
- **Pages:** Home (0), Bookings (1), Notifications (2), More (3)
- **Controller:** `MainNavigationController` — persists navigation state to storage

### 7. More (`features/more/`)
- **Screen:** More Page — Support Center (Call, WhatsApp, Email), Settings, Terms & Conditions, Privacy Policy, Logout
- **Controller:** `MoreController` — handles logout with confirmation, contact actions

### 8. Settings (`app/Setting/`)
- **Screen:** Settings Page (theme, language preferences)

### 9. Notifications (`features/notification/`)
- **Screen:** Notifications Page

### 10. Setup/Splash (`features/setupfeature/`)
- **Screen:** Splash Screen (5-second display)
- **Controller:** `SplashScreenController` — initializes auth state, navigates based on auth status

---

## Core Layer

### Network (`core/network/`)
- **ApiClient:** HTTP client with request/response interceptors
- **AuthInterceptor:** Auto-injects Bearer token, handles 401 with token refresh + retry, excludes auth endpoints from token injection

### Storage (`core/services/storage_service.dart`)
- **FlutterSecureStorage** with encrypted shared preferences (Android)
- Read/Write/Remove/Clear operations with type casting

### Models (`core/shared/model/`)
- **UserModel:** id, username, email, firstName, lastName, phoneNumber, isActive, roles
- **ApiResponse:** Generic wrapper for API responses (success, message, data)

### Error Handling (`core/errors/`)
- **Exceptions:** AppException, AuthenticationException, ValidationException, ServerException, NetworkException, TimeoutException, CacheException, ParsingException, NavigationException
- **Failures:** Failure, NetworkFailure, ServerFailure, TimeoutFailure (for Either pattern with dartz)
- **ErrorHandler:** Centralized logging and error message generation

### Middleware (`core/middleware/`)
- **AuthMiddleware:** Route protection — redirects unauthenticated users to Login, authenticated users away from auth pages
- **Protected routes:** MainNavigation, Home, Profile, Settings, Dashboard, EditProfile
- **Guest-only routes:** Login, Register, ForgotPassword, ResetPassword

### Config (`core/config/`)
- **Environment configs:** Dev, Staging, Prod — each with its own base URL
- **EnvironmentService:** Provides config values (API base URL) at runtime

---

## Dependency Injection (InitialBinding)
```
StorageService → ApiClient (+ AuthInterceptor) → AuthDataSource → AuthRepository → AuthStateController (permanent) → SplashScreenController
```
Also registers: ThemeService, TranslationService

---

## API Endpoints (ApiConstants)
| Category | Endpoints |
|----------|-----------|
| **Auth** | `/Auth/login`, `/Auth/register`, `/Auth/logout`, `/Auth/refresh`, `/Auth/forgot-password`, `/Auth/reset-password`, `/Auth/{operation}/verify`, `/Auth/me` |
| **Home** | `/Home/index`, `/Home/restaurant/{restaurantId}/gallery` |
| **Restaurant** | `/Restaurant/business-hours`, `/Restaurant/policies` |
| **Reservation** | `/Reservation/check-availability`, `/Reservation/create`, `/Reservation/confirm`, `/Reservation/my-reservations`, `/Reservation/{bookingId}` |
| **Profile** | `/Profile`, `/Profile/password`, `/Profile/phone/change`, `/Profile/phone/verify` |

---

## Key Dependencies
| Package | Purpose |
|---------|---------|
| `get` | State management, DI, routing |
| `http` | HTTP client |
| `flutter_secure_storage` | Encrypted local storage |
| `dartz` | Functional programming (Either pattern) |
| `moyasar` | Payment gateway |
| `table_calendar` | Calendar widget for reservations |
| `cached_network_image` | Image caching |
| `geolocator` | Location services |
| `sentry_flutter` | Crash reporting |
| `iconsax` | Icon set |
| `qr_flutter` | QR code generation |
| `url_launcher` | External links (phone, WhatsApp, email) |

---

## Current Auth Flow (What Needs to Change for Guest Mode)
1. App starts → SplashScreen → checks stored tokens
2. If authenticated → MainNavigationScaffold
3. If NOT authenticated → LoginPage (only option)
4. **All protected routes require authentication** — no guest access
5. **AuthMiddleware blocks** unauthenticated users from Home, Bookings, Profile, etc.
6. **AuthInterceptor** injects tokens on every API call (except auth endpoints)
7. **HomeController** loads user data on init — assumes user exists
8. **BookingsPage** fetches user's reservations — requires auth
9. **ProfileHeader** requires `UserModel` — will break without user data
10. **MorePage** has logout button — only relevant for authenticated users

---

## Areas Affected by Guest Feature
- `AuthMiddleware` — needs to allow guests to access certain routes
- `SplashScreenController` — needs a "Continue as Guest" path
- `LoginPage` — needs a "Continue as Guest" button
- `AuthStateController` — needs guest state tracking
- `MainNavigationScaffold` — may need to hide/modify tabs for guests
- `HomeController` — needs to handle null user gracefully (partially done)
- `ProfileHeader` — needs guest fallback display
- `BookingsPage` — needs to block/redirect guests
- `ReservationController` — needs to block/redirect guests at confirmation
- `MorePage` — needs to show "Login" instead of "Logout" for guests
- `AuthInterceptor` — API calls without token for guest-accessible endpoints
- `StorageConstants` — may need `isGuest` key
