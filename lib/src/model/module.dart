import 'route.dart';

abstract class Module {
  final String _path;
  final bool _allowAnonymous;

  Module({
    required String path,
    bool allowAnonymous = false,
  }) : _path = path,
       _allowAnonymous = allowAnonymous;

  String get name => _path;
  bool get allowAnonymous => _allowAnonymous;

  List<ModuleRoute> get routes;
  List<Module> get modules => [];
}
