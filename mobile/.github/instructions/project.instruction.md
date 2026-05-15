# 🤖 GitHub Copilot Instructions: MenteCart Flutter App

> **Purpose:** Guide AI-assisted code generation to match the assessment's architecture, state management, networking, and edge-case handling requirements. All generated code must be production-leaning, BLoC-compliant, and assessment-ready.

---

## 📐 1. Architecture & Project Structure

- **Pattern:** Feature-First Clean Architecture
- **Folder Layout:**
  ```
  lib/
  ├── core/          # Constants, theme, errors, utils
  ├── config/        # Routes, env, DI setup
  ├── features/      # Isolated feature modules
  │   ├── auth/
  │   ├── services/
  │   ├── cart/
  │   ├── checkout/
  │   └── bookings/
  │       ├── presentation/
  │       │   ├── bloc/
  │       │   └── pages/
  │       ├── domain/
  │       └── data/
  └── shared/        # Reusable widgets, API client, interceptors
  ```
- **Rule:** UI never talks directly to APIs. Always go through `Repository → DataSource → API Client`.
- **Rule:** No business logic in widgets or BLoCs. Domain usecases handle rules.

---

## 🔄 2. State Management (BLoC REQUIRED)

- **Package:** `flutter_bloc` (latest stable)
- **Events & States:** Use `sealed class` for type-safe exhaustiveness.
  ```dart
  sealed class CartEvent {}
  sealed class CartState {}
  ```
- **Required States per Feature:** `Initial`, `Loading`, `Success`, `Error`, `Empty`
- **Allowed:** `BlocProvider`, `BlocBuilder`, `BlocListener`, `BlocConsumer`
- **Forbidden:** `setState` for app state. Only allowed for local UI toggles (e.g., expanding a tile, showing a password).
- **Rule:** Every async action must emit `Loading → Success/Error`. Never skip loading state.

---

## 🌐 3. Networking & API Client

- **Package:** `dio` (preferred) or `http`
- **Single Client:** `lib/shared/services/api_client.dart`
- **Interceptors Required:**
  1. `AuthInterceptor`: Attaches `Bearer <token>` from secure storage
  2. `ErrorInterceptor`: Maps HTTP codes → `AppException(statusCode, message, errorCode)`
  3. `RetryInterceptor` (optional): Retry 401 once with token refresh
- **Environment Config:** Use `--dart-define=API_BASE_URL`. Never hardcode URLs.
- **Rule:** All network calls return `Either<Failure, Success>` or throw typed `AppException`. Never return raw `Response` objects to UI.

---

## 🛡️ 4. Error Handling & Validation

- **Global Error Class:**
  ```dart
  class AppException implements Exception {
    final int statusCode;
    final String message;
    final String? errorCode;
    const AppException({required this.statusCode, required this.message, this.errorCode});
  }
  ```
- **Validation:** Use `formz` or manual regex for email/password. Show inline field errors.
- **User Feedback:**
  - `SnackBar` for transient errors (network, timeout)
  - `Dialog` for critical failures (payment, checkout)
  - Retry buttons on failed list loads
- **Rule:** Never show raw API messages to users. Map `errorCode` → user-friendly strings.

---

## 🎨 5. UI/UX & Component Standards

- **Design:** Material 3, consistent spacing/padding (`kSpacingUnit * 4, 8, 16`)
- **Status Badges (Color-Coded):**
  - `pending` → Amber 🟡
  - `confirmed` → Green 🟢
  - `completed` → Blue 🔵
  - `cancelled` / `failed` → Red 🔴
- **Empty States:** Always include illustration + CTA button (e.g., "Browse Services")
- **Loading:**
  - Lists → `Shimmer` effect
  - Actions → `CircularProgressIndicator` + disabled buttons
- **Required Widgets:** `TimeSlotPicker`, `StatusBadge`, `ServiceCard`, `BookingCard`, `PullToRefreshWrapper`
- **Rule:** Handle `null`, empty lists, and network loss gracefully in every screen.

---

## 📝 6. Copilot Prompt Templates

Use these exact patterns to get assessment-compliant output:

| Task                | Prompt                                                                                                                                                    |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **BLoC Setup**      | `Generate a BLoC for [Feature] with events: Load, Add, Remove, Update. Use sealed classes for events/states. Include loading/success/error/empty states.` |
| **API Call**        | `Create a Dio-based repository method for POST /cart/items. Attach JWT interceptor. Map errors to AppException. Return Either<Failure, CartModel>.`       |
| **UI List**         | `Build a paginated services list grid with pull-to-refresh, shimmer loading, empty state, and category filter chips. Use BlocBuilder.`                    |
| **Form Validation** | `Create a login form with email/password validation, loading button state, and centralized error handling via AppException mapping.`                      |
| **Status Badge**    | `Create a reusable StatusBadge widget that takes BookingStatus and returns correct color/icon. Use sealed class switch.`                                  |

---

## 🚫 7. What to AVOID (Copilot Anti-Patterns)

- ❌ `Provider`, `Riverpod`, `GetX`, or `ValueNotifier` for app state
- ❌ `setState(() {})` for anything beyond local widget toggles
- ❌ Hardcoded API URLs, tokens, or PayHere secrets
- ❌ Raw `print()` for logging. Use `debugPrint()` or structured logger
- ❌ Ignoring `null` safety or using `!` operator without validation
- ❌ Mixing UI and business logic in the same file
- ❌ Returning `200 OK` with error messages in body. Use proper HTTP codes.

---

## ✅ 8. Assessment Compliance Checklist

When generating or reviewing code, verify:

- [ ] BLoC pattern used exclusively for state
- [ ] Cart requires date + time slot before adding
- [ ] Slot picker disables full/expired slots
- [ ] Cart expiry handled (show warning, refresh state)
- [ ] Booking status lifecycle visualized (timeline/badges)
- [ ] Cancellation button disabled past cutoff window
- [ ] All API calls wrapped in interceptors + error mappers
- [ ] No secrets in repo. Use `.env` + `dart-define`
- [ ] README documents run steps, env vars, limitations

---

> 💡 **Pro Tip for Copilot:** Prefix prompts with `[MenteCart Assessment]` to force adherence to these rules. Example:  
> `[MenteCart Assessment] Generate a CheckoutBloc with events: InitiateCheckout, ConfirmBooking. Handle payment method branching (payhere vs cash). Emit loading/success/error. Use Dio API client.`
