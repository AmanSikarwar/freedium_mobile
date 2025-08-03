# Freedium Mobile - Copilot Instructions & Guidelines

This document provides a set of instructions, architectural guidelines, and best practices for developing the Freedium Mobile application. The goal is to ensure the codebase remains clean, scalable, maintainable, and easy for multiple developers to contribute to.

## 1. Guiding Principles

- **Separation of Concerns**: Code should be organized into distinct layers, primarily the Presentation, Domain, and Data layers. This makes the app more modular and testable.
- **Unidirectional Data Flow**: Data flows in one direction: from the data layer to the presentation layer. UI events can trigger updates, but these updates must originate from the business logic or data layers, not directly within the widgets themselves.
- **Immutability**: State objects and data models should be immutable to prevent unintended side effects and make state management more predictable.
- **Dependency Injection**: Dependencies should be provided to classes rather than being created within them. This promotes loose coupling and improves testability.

## 2. Recommended Architecture: Clean Architecture

We will follow the principles of Clean Architecture, which divides the application into three primary layers.

- **Presentation Layer**: Responsible for the UI and handling user input. It contains widgets and state management logic (Providers). It knows about the Domain Layer but not the Data Layer.
- **Domain Layer**: The core of the application. It contains the business logic, use cases (application-specific business rules), and entities (business objects). This layer is independent of Flutter and any external packages.
- **Data Layer**: Responsible for all data operations. It includes repositories, which abstract the data sources (API, local database, etc.), and the data sources themselves. This layer knows about the Domain Layer (to implement its interfaces) but not the Presentation Layer.

### Folder Structure

To enforce this separation, the `lib` directory should be organized by feature, with each feature containing its own layers:

```
lib/
├── core/                  # Shared code, utilities, and base classes
│   ├── constants/         # Application-wide constants
│   ├── services/          # Abstracted services (e.g., API, storage)
│   ├── theme/             # App theme definitions
│   └── widgets/           # Common, reusable widgets
│
├── features/              # Feature-specific code
│   └── <feature_name>/
│       ├── presentation/
│       │   ├── <screen_name>_screen.dart
│       │   └── widgets/
│       │       └── <widget_name>.dart
│       ├── application/   # State management and use cases
│       │   ├── <state_provider_name>.dart
│       │   └── use_cases/
│       │       └── <use_case_name>.dart
│       ├── domain/        # Business models and repository interfaces
│       │   ├── <model_name>.dart
│       │   └── repositories/
│       │       └── <repository_interface>.dart
│       └── data/          # Data sources and repository implementations
│           ├── datasources/
│           │   └── <data_source_name>.dart
│           └── repositories/
│               └── <repository_implementation>.dart
│
├── app.dart               # MaterialApp and root widget setup
└── main.dart              # App entry point
```

## 3. State Management: Riverpod

We use the **Riverpod** package for state management and dependency injection.

- **Why Riverpod?**: It offers compile-time safety, is easy to test, and allows for providing dependencies and managing state without being tied to the widget tree.

### Provider Naming Conventions:

- **`myLogicProvider`**: For simple providers that expose a service or a value.
- **`myLogicProvider.notifier`**: To access the `StateNotifier` class itself to call its methods.
- **`myLogicProvider` (watching)**: To listen to the state of a `StateNotifier` and rebuild the UI when it changes.

### Best Practices:

- **Use `StateNotifierProvider`**: For managing complex state that can change over time. The state object itself should be immutable.
- **Use `Provider`**: For exposing dependency-injected services (e.g., `UserRepository`).
- **Use `FutureProvider` / `StreamProvider`**: For handling asynchronous data from APIs or streams.
- **Use `.family`**: To create providers that take external parameters.
- **Keep Providers Focused**: A provider should have a single responsibility.

## 4. Code Style and Conventions

We adhere to the official [Effective Dart](https://dart.dev/effective-dart) guidelines. The `flutter_lints` package is used to enforce these rules.

### Naming

- **Files**: `snake_case.dart` (e.g., `home_screen.dart`).
- **Classes & Enums**: `PascalCase` (e.g., `HomeViewModel`, `Status`).
- **Variables & Functions**: `camelCase` (e.g., `userName`, `fetchUserData`).
- **Constants**: `camelCase` (e.g., `defaultPadding`).
- **Widgets**: Name widgets for what they are or do (e.g., `UserProfileCard`).
- **Screens**: Suffix screen widgets with `Screen` (e.g., `HomeScreen`).
- **Providers**: Suffix provider names with `Provider` (e.g., `userServiceProvider`).

### Formatting

- Run `dart format .` regularly to ensure consistent formatting.
- Add trailing commas to parameter lists with multiple lines to improve auto-formatting.
- Keep line length under 80 characters where possible for better readability.

### Documentation

- **Public APIs**: All public functions, classes, and variables should have Dartdoc comments (`///`).
- **Complex Logic**: Add comments (`//`) to explain complex or non-obvious parts of the code.
- **`@override`**: Always use the `@override` annotation for overridden methods.

## 5. Best Practices

### Widgets

- **Keep Widgets Small and Reusable**: Break down large widgets into smaller, more manageable ones.
- **Prefer `const` Constructors**: Use `const` for widgets whenever possible to improve performance by reducing unnecessary rebuilds.
- **Avoid Business Logic in Widgets**: The presentation layer should be as "dumb" as possible. UI widgets should only be responsible for displaying state and forwarding user events to the state management layer.

### Asynchronous Code

- **Use `async/await`**: For a clear, readable asynchronous style.
- **Handle Errors Gracefully**: Always include `try-catch` blocks for operations that can fail, like network requests. In Riverpod, `AsyncValue` (`.when`, `.error`, `.loading`) should be used to handle different states of an async operation in the UI.

### Asset Management

- **Centralize Asset Paths**: Define asset paths as constants in a dedicated file (e.g., `core/constants/asset_constants.dart`) to avoid typos.
- **Optimize Images**: Compress images and use appropriate formats (e.g., WebP) to reduce app size.
- **Use `.svg` for Icons**: Prefer SVG for icons that need to scale without quality loss, using the `flutter_svg` package.

### Testing

- **Unit Tests**: Write unit tests for all business logic in the Domain and Data layers (Use Cases, Repositories).
- **Widget Tests**: Write widget tests for all UI components and screens to verify UI state and behavior.
- **Integration Tests**: Write integration tests for critical user flows to ensure all layers of the application work together correctly.