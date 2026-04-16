# Modular Router 🚀

[![Pub Version](https://img.shields.io/pub/v/modular_router?style=flat-square&color=blue)](https://pub.dev/packages/modular_router)
[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://github.com/TercyoStorck/modular_router/blob/master/LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-sdk-blue.svg?style=flat-square&logo=flutter)](https://flutter.dev)

A powerful, modular, and type-safe routing solution for Flutter applications. Manage complex navigation structures, dependency injection, and authorization with ease.

---

## ✨ Features

- **🏆 Modular Architecture**: Organize your app into logical features (modules).
- **🌲 Nested Routing**: Create hierarchical path structures effortlessly.
- **💉 Built-in Dependency Injection**: Powered by `auto_injector` and `dynamic_constructor`.
- **🛡️ Integrated Authorization**: Control access at both module and route levels.
- **📍 Type-Safe Navigation**: Navigate using types instead of hardcoded strings.
- **📱 Platform-Native Transitions**: Automatic Material/Cupertino transitions.
- **🎨 Custom Transitions**: Full control over page transitions when needed.
- **🔧 Stateful Integration**: Seamlessly binds `Controller`s to `StatefulWidgetBinder` views.

---

## 🚀 Getting Started

### 1. Installation

Add `modular_router` to your `pubspec.yaml`:

```yaml
dependencies:
  modular_router: ^2.0.0
```

### 2. Define your Modules and Routes

Create a module by extending `Module` and define its routes. Views should extend `StatefulWidgetBinder` and Controllers should implement `DisposableController`.

```dart
class UserModule extends Module {
  UserModule() : super(path: '/user');

  @override
  List<ModuleRoute> get routes => [
    ModuleRoute<ProfilePage>(
      path: '/profile',
      viewBuilder: ProfilePage.new,
      controllerBuilder: ProfileController.new,
    ),
    ModuleRoute<SettingsPage>(
      path: '/settings',
      viewBuilder: SettingsPage.new,
      controllerBuilder: SettingsController.new,
    ),
  ];
}
```

### 3. Initialize the Router

Create your router and pass its `onGenerateRoute` to your `MaterialApp`.

```dart
final router = ModularRouter(
  modules: [
    UserModule(),
    // ... other modules
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: router.onGenerateRoute,
      initialRoute: '/user/profile',
    );
  }
}
```

---

## 💉 Dependency Injection

`ModularRouter` uses `auto_injector` to handle dependencies. You can register factories, lazy singletons, or singletons during initialization:

```dart
final router = ModularRouter(
  modules: [ ... ],
  factories: [
    Injector<AuthService>(AuthService.new),
  ],
  singletons: [
    Injector<ApiClient>(ApiClient.new),
  ],
);
```

Or by extending `ModularRouter`:

```dart
class MyRouter extends ModularRouter {
  MyRouter({required super.modules}) : super(
    factories: [ ... ],
  );
}
```

Dependencies are automatically injected into your `viewBuilder` and `controllerBuilder` based on their constructor parameters!

#### Required Base Classes

For DI and binding to work, follow these base class requirements:

- **Views**: Must extend `StatefulWidgetBinder`.
- **Controllers**: Must implement `DisposableController` (or use `ListenableController` for reactivity).

```dart
class MyController extends ListenableController {
  @override
  void dispose() {
    super.dispose();
  }
}

class MyPage extends StatefulWidgetBinder {
  const MyPage({required super.controller, super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}
```

---

## 📍 Type-Safe Navigation

Forget about hardcoded path strings. Use the provided extensions on `NavigatorState`:

```dart
// Push to a specific view type
Navigator.of(context).pushTo<ProfilePage>();

// Push and replace
Navigator.of(context).pushToReplacement<SettingsPage>();

// Push and remove until
Navigator.of(context).pushToAndRemoveUntil<DashboardPage, LoginPage>();

// Pop all and push
Navigator.of(context).popAllAndPushTo<HomePage>();
```

---

## 📦 Passing Arguments

`ModularRouter` makes it incredibly easy to pass data directly into your controller or view constructors. The system handles DI automatically, but you can also pass custom arguments via the `Navigator`:

### 1. Positional Arguments
Just pass your arguments as a `List`:

```dart
// Controller constructor: SettingsController(this.username, this.userId)
Navigator.of(context).pushTo<SettingsPage>(
  arguments: ['tercyo', 123],
);
```

### 2. Named Arguments
Pass your arguments as a `Map`:

```dart
// Controller constructor: ProfileController({required String bio})
Navigator.of(context).pushTo<ProfilePage>(
  arguments: {'bio': 'Always building 🚀'},
);
```

### 3. Mixed Arguments
Pass a `List` with a `Map` as the last element:

```dart
// Controller constructor: UserDetailController(this.userId, {required String source})
Navigator.of(context).pushTo<UserDetailPage>(
  arguments: [123, {'source': 'profile_view'}],
);
```

---

## 🛡️ Authorization

You can easily protect routes or entire modules:

```dart
class AdminModule extends Module {
  AdminModule() : super(
    path: '/admin',
    allowAnonymous: false, // Requires authorization
  );

  @override
  List<ModuleRoute> get routes => [
    ModuleRoute<Dashboard>(
      path: '/',
      viewBuilder: AdminDashboard.new,
    ),
    ModuleRoute<PublicInfo>(
      path: '/info',
      viewBuilder: PublicInfoPage.new,
      allowAnonymous: true, // Override module setting
    ),
  ];
}
```

Initialize your router with the current auth state:

```dart
final router = MainRouter(
  modules: [...],
  enableAuthorize: true,
  authorized: userIsLoggedIn,
  unauthorizedRedirectRoute: '/login',
);
```

---

## 🛠️ Advanced Usage

### Custom Page Transitions

```dart
ModuleRoute<PremiumPage>(
  path: '/premium',
  viewBuilder: PremiumPage.new,
  customPageTransition: <T>({settings, required view}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => view,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  },
);
```

---

## 🎨 Example

Check out the [example](example/lib/main.dart) project for a complete demonstration, including:

- **Module and Route definitions**
- **Dependency Injection** with a global `Config` object
- **Counter state management** using `ListenableController`
- **Type-safe Navigation** using `NavigatorStateExtension`

---

## 📄 License

This project is licensed under the GNU GPL v3 License - see the [LICENSE](LICENSE) file for details.