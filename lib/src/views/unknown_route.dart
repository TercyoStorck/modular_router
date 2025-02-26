import 'package:flutter/material.dart';

class UnknownRoute extends StatelessWidget {
  final String? routeName;

  const UnknownRoute({
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Route $routeName is not found!',
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
