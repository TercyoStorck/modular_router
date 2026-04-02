import 'package:modular_router/modular_router.dart';
import 'package:modular_router/src/exception.dart';
import 'package:modular_router/src/model/routing/routing.dart';
import 'package:stateful_widget_binder/stateful_widget_binder.dart';

class RoutingMap {
  final List<Routing> _routingMap;

  RoutingMap(this._routingMap);

  Routing getByPath(String path) {
    final normalizedPath = _normalizePath(path);
    return _routingMap.firstWhere(
      (e) => _normalizePath(e.path) == normalizedPath,
      orElse: () => throw UnknownRouteException(),
    );
  }

  Routing getByView<T extends StatefulWidgetBinder>() {
    return _routingMap.firstWhere((e) => e.view == T);
  }

  Routing getByModule<T extends Module>() {
    return _routingMap.firstWhere((e) => e.module == T);
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
}
