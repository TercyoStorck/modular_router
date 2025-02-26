import 'route.dart';

abstract class Module {
  String get name;
  bool get allowAnonymous => false;
  List<ModuleRoute> get routes;
  List<Module> get modules => [];
}