# Mobile Application Architecture & Usage Guide

The mobile client is built with **Flutter 3** using **Material Design 3**, serving both Android devices and Web browsers from a unified codebase.

---

## Technical Stack & Libraries

- **Framework**: Flutter 3.19+ (Dart 3.3+)
- **State Management**: `flutter_riverpod` (StateNotifier & Providers)
- **Navigation & Routing**: `go_router` (Declarative router with auth redirect guards)
- **HTTP Client**: `dio` (Interceptor-driven API client with automatic JWT header injection and exception handling)
- **Secure Token Storage**: `flutter_secure_storage` (Android Keystore / iOS Keychain) with SharedPreferences fallback for web
- **Testing**: `flutter_test`, `mocktail`

---

## Network & Offline Error Handling

1. **No Internet / Network Error**:
   - `ApiService` catches `SocketException` and `connectionTimeout` exceptions and surfaces user-friendly notices ("No Internet connection" / "Connection timed out").
   - Screens feature pull-to-refresh (`RefreshIndicator`) allowing instant retries without requiring app restart.
   
2. **Token Expiration (401 Unauthorized)**:
   - When the backend responds with HTTP 401 on protected routes, `AuthNotifier` clears cached credentials and `GoRouter` smoothly redirects the user to `/login`.
   
3. **Data Cache & Resilience**:
   - During temporary offline network drops, cached user credentials stored in secure storage maintain UI state without flashing blank login screens.

---

## Building & Deployment

### Build Debug Android APK
```bash
cd mobile
flutter build apk --debug
```
The generated APK file will be located at:
`mobile/build/app/outputs/flutter-apk/app-debug.apk`

### Build Web Bundle
```bash
cd mobile
flutter build web
```
The output static web assets will be generated in `mobile/build/web`.

