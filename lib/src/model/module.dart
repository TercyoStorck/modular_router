import 'route.dart';

abstract class RouterModule {
  final String _name;
  final bool _allowAnonymous;

  RouterModule({
    required String name,
    bool allowAnonymous = false,
  })  : _name = name,
        _allowAnonymous = allowAnonymous;

  String get name => _name;
  bool get allowAnonymous => _allowAnonymous;

  List<ModuleRoute> get routes;
  List<RouterModule> get modules => [];
}
