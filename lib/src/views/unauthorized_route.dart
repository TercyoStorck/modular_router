import 'package:flutter/material.dart';
import 'package:stateful_widget_binder/stateful_widget_binder.dart';

class UnauthorizedRoute extends StatefulWidgetBinder {
  const UnauthorizedRoute({required super.controller});

  @override
  State<UnauthorizedRoute> createState() => _UnauthorizedRouteState();
}

class _UnauthorizedRouteState extends State<UnauthorizedRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Unauthorized access',
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
