import 'package:flutter/material.dart';
import 'package:stateful_widget_binder/stateful_widget_binder.dart';

class UnknownRoute extends StatefulWidgetBinder {
  final String? routeName;

  const UnknownRoute({
    this.routeName,
    required super.controller,
  });

  @override
  State<UnknownRoute> createState() => _UnknownRouteState();
}

class _UnknownRouteState extends State<UnknownRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Route ${widget.routeName} is not found!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 36.0,
          ),
        ),
      ),
    );
  }
}
