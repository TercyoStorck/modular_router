import 'package:flutter/widgets.dart';

class ModuleRoute<T> {
  final String path;
  final bool allowAnonymous;
  final bool isFullscreenDialog;
  final Widget Function() builder;

  Type get type => T;

  ModuleRoute({
    required this.path,
    this.allowAnonymous = false,
    this.isFullscreenDialog = false,
    required this.builder,
  });
}
