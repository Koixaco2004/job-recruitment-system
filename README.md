# Flutter Clean Architecture Project

This project uses **Clean Architecture** to ensure detailed separation of concerns, testability, and scalability.

## 📂 Folder Structure

The code is organized into `core` and `features`.

### 1. Core (`lib/core/`)
Contains code shared across multiple features.

- **`constants/`**: Static values like API endpoints, colors, strings (e.g., `api_constants.dart`).
- **`error/`**: Custom `Failure` and `Exception` classes.
- **`utils/`**: Helper functions (date formatting, input validation).
- **`network/`**: Network client configuration (Dio setup, interceptors).
- **`widgets/`**: Reusable generic UI components (buttons, loaders).

### 2. Features (`lib/features/`)
Each feature (e.g., `auth`, `jobs`, `profile`) is a self-contained module with three layers:

#### **Domain Layer** (Inner Layer - Pure Dart)
*No external dependencies (Flutter, Data, etc.)*
- **`entities/`**: Business logic objects.
- **`repositories/`**: Abstract interfaces defining *what* the feature can do.
- **`usecases/`**: Specific business actions (e.g., `LoginUseCase`).

#### **Data Layer** (Middle Layer)
*Handles data retrieval and transformation.*
- **`models/`**: Data Transfer Objects (DTOs) that extend Entities (handles JSON parsing).
- **`datasources/`**: Interface and impl for remote (API) and local (DB) data.
- **`repositories/`**: Implementation of Domain repositories.

#### **Presentation Layer** (Outer Layer)
*UI and State Management.*
- **`pages/`**: Full screens/views.
- **`widgets/`**: Feature-specific UI components.
- **`bloc/`** or **`provider/`**: State management logic.

## 📦 Essential Packages

This project includes the following key libraries:

| Package | Purpose |
| :--- | :--- |
| **[dio](https://pub.dev/packages/dio)** | Powerful HTTP client for API calls. Supports interceptors, global configuration, etc. |
| **[provider](https://pub.dev/packages/provider)** | Dependency injection and state management. |
| **[shared_preferences](https://pub.dev/packages/shared_preferences)** | Persistent storage for simple data (like Auth Tokens). |
| **[cached_network_image](https://pub.dev/packages/cached_network_image)** | Efficient image loading with caching support. |
| **[equatable](https://pub.dev/packages/equatable)** |  Simplifies object comparison (useful for State and Models). |
| **[get_it](https://pub.dev/packages/get_it)** | (Recommended) Service Locator for Dependency Injection. |

## 🚀 Getting Started

1.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Run App**:
    ```bash
    flutter run
    ```
