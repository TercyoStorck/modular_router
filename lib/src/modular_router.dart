import 'dart:io' show Platform;

import 'package:auto_injector/auto_injector.dart' hide Injector;
import 'package:collection/collection.dart';
import 'package:dynamic_constructor/dynamic_constructor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modular_router/src/model/injector.dart';
import 'package:modular_router/src/model/routing/routing.dart';
import 'package:modular_router/src/model/routing/routing_map.dart';
import 'package:stateful_widget_binder/stateful_widget_binder.dart';

import 'exception.dart';
import 'model/module.dart';
import 'model/route.dart';
import 'page_route/cupertino.dart';
import 'page_route/default.dart';
import 'page_route/material.dart';
import 'views/unauthorized_route.dart';
import 'views/unknown_route.dart';

class ModularRouter {
  static ModularRouter? _instance;
  static ModularRouter get instance {
    if (_instance == null) {
      throw Exception('ModularRouter: Call constructor before access instance');
    }
    return _instance!;
  }

  final List<Module> _modules;
  final bool _enableAuthorize;
  final bool _authorized;
  final String _unauthorizedRedirectRoute;
  final _injector = AutoInjector();
  late final RoutingMap _routingMap;

  ModularRouter({
    required List<Module> modules,
    List<Injector>? factories,
    List<Injector>? lazySingletons,
    List<Injector>? singletons,
    bool enableAuthorize = true,
    bool authorized = false,
    String unauthorizedRedirectRoute = '',
  }) : _unauthorizedRedirectRoute = unauthorizedRedirectRoute,
       _authorized = authorized,
       _enableAuthorize = enableAuthorize,
       _modules = modules {
    _routingMap = _buildRoutingMap();
    _instance = this;

    _registerInjectors(factories, lazySingletons, singletons);
    _injector.commit();
  }

  static RoutingMap get routingMap => instance._routingMap;

  void _registerInjectors(List<Injector>? factories, List<Injector>? lazySingletons, List<Injector>? singletons) {
    for (var factory in factories ?? <Injector>[]) {
      _injector.add(factory.constructor, key: factory.injectedType.toString());
    }

    for (var lazySingleton in lazySingletons ?? <Injector>[]) {
      _injector.addLazySingleton(lazySingleton.constructor, key: lazySingleton.injectedType.toString());
    }

    for (var singleton in singletons ?? <Injector>[]) {
      _injector.addSingleton(singleton.constructor, key: singleton.injectedType.toString());
    }
  }

  RoutingMap _buildRoutingMap() {
    final List<Routing> routings = [];
    for (final module in _modules) {
      _fillRoutings(routings, module, '');
    }
    return RoutingMap(routings);
  }

  void _fillRoutings(List<Routing> routings, Module module, String parentPath) {
    final String currentPath = _normalizePath('$parentPath/${module.name}');

    for (final route in module.routes) {
      final String fullPath = _normalizePath('$currentPath/${route.path}');
      routings.add(
        Routing(
          view: route.viewRuntimeType,
          module: module.runtimeType,
          path: fullPath,
        ),
      );
    }

    for (final subModule in module.modules) {
      _fillRoutings(routings, subModule, currentPath);
    }
  }

  String _normalizePath(String path) {
    String normalized = path.replaceAll(RegExp(r'/+'), '/');
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized.isEmpty ? '/' : normalized;
  }

  Route<T> onGenerateRoute<T>(RouteSettings routeSettings) {
    final String? path = routeSettings.name;
    if (path == null || path.isEmpty) {
      throw Exception('ModuleRouter: Provide a path');
    }

    return _router<T>(routeSettings);
  }

  Route<T> _router<T>(RouteSettings routeSettings) {
    try {
      final path = routeSettings.name;
      if (path == null) throw UnknownRouteException();

      final routing = _routingMap.getByPath(path);

      final module = _modules.firstWhere((module) => module.runtimeType == routing.module);
      final route = module.routes.firstWhereOrNull((route) => route.viewRuntimeType == routing.view);

      if (route == null) throw UnknownRouteException();

      if (_enableAuthorize && !(_authorized || module.allowAnonymous || route.allowAnonymous)) {
        throw UnauthorizedRouteException();
      }

      return _pageRouter<T>(route, routeSettings);
    } on UnknownRouteException catch (_) {
      return _unknownPageRoute(routeSettings);
    } on UnauthorizedRouteException catch (_) {
      if (_unauthorizedRedirectRoute.isNotEmpty) {
        return _router(RouteSettings(name: _unauthorizedRedirectRoute));
      }
      return _unauthorizedPageRoute();
    }
  }

  PageRoute<T> _pageRouter<T>(ModuleRoute route, RouteSettings? routeSettings) {
    final arguments = routeSettings?.arguments is List 
      ? List<dynamic>.from(routeSettings?.arguments as List) 
      : [routeSettings?.arguments];

    final controllerSignature = _parseSignature(route.controllerBuilder);

    // Prepare arguments for controller
    final positionalArgTypes = _splitTypes(controllerSignature.positional ?? '');
    final positionalArgs = positionalArgTypes.map((e) {
      final fromInjector = _injector.tryGet(key: e);
      if (fromInjector != null) return fromInjector;
      if (arguments.isNotEmpty) return arguments.removeAt(0);
      return null;
    }).toList();

    // Prepare named arguments for controller
    final Map<String, dynamic> namedArgs = {};
    if (controllerSignature.named != null) {
      final typeRegex = RegExp(r'\b(?!(?:required)\b)([A-Z][a-zA-Z0-9_]*)');
      final params = controllerSignature.named!.split(',');
      for (final p in params) {
        final type = typeRegex.firstMatch(p)?.group(0);
        final name = p.trim().split(' ').last.trim();
        final value = _injector.tryGet(key: type);
        namedArgs[name] = value;
      }
    }

    final controllerParams = [...positionalArgs];
    if (namedArgs.isNotEmpty) {
      controllerParams.add(namedArgs);
    }

    final controller = DynamicConstructor(route.controllerBuilder, controllerParams).instance;

    // Prepare arguments for view
    final Map<String, dynamic> viewNamedArgs = Map.from(namedArgs);
    if (controller != null) {
      viewNamedArgs['controller'] = controller;
    }

    final viewSignature = _parseSignature(route.viewBuilder);
    final viewParams = [];
    
    // Add positional controller if expected
    if (viewSignature.positional != null || (viewSignature.positional == null && viewSignature.named == null)) {
      if (controller != null) viewParams.add(controller);
    }

    // Add named arguments if expected
    if (viewSignature.named != null && viewNamedArgs.isNotEmpty) {
      viewParams.add(viewNamedArgs);
    }

    final Widget view = DynamicConstructor<Widget>(route.viewBuilder, viewParams).instance;

    if (route.customPageTransition != null) {
      return route.customPageTransition!<T>(settings: routeSettings, view: view);
    }

    if (Platform.isAndroid) {
      return CustomMaterialRoute<T>(
        fullscreenDialog: route.isFullscreenDialog,
        settings: routeSettings,
        builder: (BuildContext context) => view,
      );
    }

    if (Platform.isIOS && !route.isFullscreenDialog) {
      return CustomCupertinoRoute<T>(
        fullscreenDialog: route.isFullscreenDialog,
        settings: routeSettings,
        builder: (BuildContext context) => view,
      );
    }

    return CustomPageRoute<T>(
      settings: routeSettings,
      fullscreenDialog: route.isFullscreenDialog,
      pageBuilder: (BuildContext context, a1, a2) => view,
    );
  }

  PageRoute<T> _unauthorizedPageRoute<T>() {
    final route = ModuleRoute<UnauthorizedRoute>(
      viewBuilder: (controller) => UnauthorizedRoute(controller: controller),
      controllerBuilder: _DefaultController.new,
      path: '',
    );
    return _pageRouter<T>(route, RouteSettings(name: _unauthorizedRedirectRoute));
  }

  PageRoute<T> _unknownPageRoute<T>(RouteSettings routeSettings) {
    final route = ModuleRoute<UnknownRoute>(
      viewBuilder: (controller) => UnknownRoute(
        routeName: routeSettings.name,
        controller: controller,
      ),
      controllerBuilder: _DefaultController.new,
      path: '',
    );
    return _pageRouter<T>(route, null);
  }

  ({String? positional, String? named}) _parseSignature(Function constructor) {
    final sig = constructor.runtimeType.toString();
    final inner = RegExp(r'^\((.*)\) =>').firstMatch(sig)?.group(1);

    if (inner == null || inner.isEmpty) {
      return (positional: null, named: null);
    }

    final braceIndex = inner.indexOf('{');
    if (braceIndex == -1) {
      return (positional: _cleanTrailingComma(inner), named: null);
    }

    final positionalRaw = inner.substring(0, braceIndex);
    final namedRaw = inner.substring(braceIndex + 1, inner.lastIndexOf('}'));

    return (
      positional: _cleanTrailingComma(positionalRaw),
      named: namedRaw.trim().isEmpty ? null : namedRaw.trim(),
    );
  }

  String _cleanTrailingComma(String s) {
    return s.trim().replaceAll(RegExp(r',\s*$'), '');
  }

  List<String> _splitTypes(String raw) {
    final result = <String>[];
    final buffer = StringBuffer();
    int depth = 0;

    for (final char in raw.split('')) {
      if (char == '<') depth++;
      if (char == '>') depth--;

      if (char == ',' && depth == 0) {
        final token = buffer.toString().trim();
        if (token.isNotEmpty) result.add(token);
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    final last = buffer.toString().trim();
    if (last.isNotEmpty) result.add(last);

    return result;
  }
}

class _DefaultController extends DisposableController {
  @override
  void dispose() {}
}
