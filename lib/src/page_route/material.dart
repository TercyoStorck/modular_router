import 'package:flutter/material.dart';

class CustomMaterialRoute<T> extends PageRoute<T> with MaterialRouteTransitionMixin<T> {
  CustomMaterialRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
    this.maintainState = true,
  });

  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) {
    final view = builder(context);

    if (super.fullscreenDialog) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.black.withOpacity(.6),
        child: SafeArea(child: view),
      );
    }

    return view;
  }

  @override
  bool get opaque => !super.fullscreenDialog;

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
