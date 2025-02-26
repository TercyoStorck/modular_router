import 'package:flutter/material.dart';

class UnauthorizedRoute extends StatelessWidget {
  const UnauthorizedRoute();

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
