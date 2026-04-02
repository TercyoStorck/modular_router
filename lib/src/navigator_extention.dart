import 'package:flutter/cupertino.dart';
import 'package:modular_router/src/modular_router.dart';
import 'package:stateful_widget_binder/stateful_widget_binder.dart';

extension NavigatorStateExtension on NavigatorState {
  Future<dynamic> pushTo<T extends StatefulWidgetBinder>({
    Object? arguments,
  }) {
    return this.pushNamed(
      ModularRouter.routingMap.getByView<T>().path,
      arguments: arguments,
    );
  }

  void pushToReplacement<T extends StatefulWidgetBinder>({
    Object? arguments,
  }) {
    this.pushReplacementNamed(
      ModularRouter.routingMap.getByView<T>().path,
      arguments: arguments,
    );
  }

  void pushToAndRemoveUntil<T extends StatefulWidgetBinder, PREDICTE extends StatefulWidgetBinder>({
    Object? arguments,
  }) {
    this.pushNamedAndRemoveUntil(
      ModularRouter.routingMap.getByView<T>().path,
      (route) {
        return route.settings.name == ModularRouter.routingMap.getByView<PREDICTE>().path;
      },
      arguments: arguments,
    );
  }

  void popAllAndPushTo<T extends StatefulWidgetBinder>({
    Object? arguments,
  }) {
    this.pushNamedAndRemoveUntil(
      ModularRouter.routingMap.getByView<T>().path,
      (route) => false,
      arguments: arguments,
    );
  }
}
