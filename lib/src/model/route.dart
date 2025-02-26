import 'package:flutter/widgets.dart';

class ModuleRoute {
  final String path;
  final bool allowAnonymous;
  final bool isFullscreenDialog;
  final Widget Function(dynamic args) builder;

  ModuleRoute({
    required this.path,
    this.allowAnonymous = false,
    this.isFullscreenDialog = false,
    required this.builder,
  });
}
