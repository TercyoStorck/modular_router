import 'package:flutter/material.dart';
import 'package:stateful_widget_binder/stateful_widget_binder.dart';

class ModuleRoute<T extends StatefulWidgetBinder> {
  final String path;
  final Function viewBuilder;
  final Function controllerBuilder;
  final bool allowAnonymous;
  final bool isFullscreenDialog;
  final PageTransitionBuilder? customPageTransition;

  ModuleRoute({
    required this.path,
    this.allowAnonymous = false,
    this.isFullscreenDialog = false,
    required this.viewBuilder,
    this.controllerBuilder = _defaultControllerBuilder,
    this.customPageTransition,
  });

  static dynamic _defaultControllerBuilder() => null;

  Type get viewRuntimeType => T;
}

typedef PageTransitionBuilder = PageRoute<T> Function<T>({RouteSettings? settings, required Widget view});
