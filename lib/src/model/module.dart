import 'route.dart';

abstract class RouterModule {
  String get path;
  bool get allowAnonymous => false;
  List<ModuleRoute> get routes;
  List<RouterModule> get modules => [];
}