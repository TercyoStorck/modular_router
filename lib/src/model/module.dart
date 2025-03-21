import 'route.dart';

abstract class RouterModule {
  final String _name;
  final bool _allowAnonymous;
  static final Map<Type, String> _routePaths = {};

  RouterModule({
    required String name,
    bool allowAnonymous = false,
  })  : _name = name,
        _allowAnonymous = allowAnonymous {
    RouterModule._routePaths.addAll({for (var route in routes) route.type: '$_name${route.path}'});
  }

  String get name => _name;
  bool get allowAnonymous => _allowAnonymous;

  List<ModuleRoute> get routes;
  List<RouterModule> get modules => [];

  static Map<Type, dynamic> get routeTo => _routePaths;
}