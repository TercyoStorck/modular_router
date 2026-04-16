import 'package:flutter/material.dart';
import 'package:modular_router/modular_router.dart';
import 'package:stateful_widget_binder/stateful_widget_binder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final router = ModularRouter(
    modules: [MainModule()],
    authorized: true, // Default to authorized for the example
    // Injecting the Config object
    singletons: [Injector<Config>(() => Config("Modular Router Demo", "v2.0.0"))],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modular Router Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      // Integrate ModularRouter
      onGenerateRoute: router.onGenerateRoute,
      initialRoute: '/',
    );
  }
}

// --- Configuration ---

class Config {
  final String appName;
  final String version;
  Config(this.appName, this.version);
}

// --- Controllers ---

class CounterController extends ListenableController {
  int count = 0;

  void increment() {
    count++;
    notifyListeners();
  }

  @override
  void dispose() {
    // Custom disposal logic if needed
    super.dispose();
  }
}

class SettingsController extends DisposableController {
  final Config config;
  final String nickname;

  SettingsController(this.config, this.nickname);

  @override
  void dispose() {
    // Custom disposal logic if needed
  }
}

// --- Views ---

class CounterPage extends StatefulWidgetBinder {
  const CounterPage({required super.controller, super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

// Use StateController to automatically bind CounterController and handle reactivity
class _CounterPageState extends StateController<CounterPage, CounterController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modular Router Counter'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('${controller.count}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushTo<SettingsPage>(arguments: 'Flutter Enthusiast'),
              icon: const Icon(Icons.settings),
              label: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: controller.increment, tooltip: 'Increment', child: const Icon(Icons.add)),
    );
  }
}

class SettingsPage extends StatefulWidgetBinder {
  const SettingsPage({required super.controller, super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends StateController<SettingsPage, SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Name: ${controller.config.appName}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Version: ${controller.config.version}', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              'User Nickname: ${controller.nickname}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const Divider(height: 32),
            const Text(
              'This page demonstrates dependency injection and dynamic parameters. The configuration was injected from the global container, while the nickname was passed via the Navigator!',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back to Home')),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Module Definition ---

class MainModule extends Module {
  MainModule() : super(path: '/');

  @override
  List<ModuleRoute> get routes => [
    ModuleRoute<CounterPage>(path: '/', viewBuilder: CounterPage.new, controllerBuilder: CounterController.new),
    ModuleRoute<SettingsPage>(path: '/settings', viewBuilder: SettingsPage.new, controllerBuilder: SettingsController.new),
  ];
}

// --- Router Initialization ---
