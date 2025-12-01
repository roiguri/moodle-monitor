import 'package:flutter/material.dart';

class OnboardingPermissionsPage extends StatelessWidget {
  final VoidCallback onFinish;

  const OnboardingPermissionsPage({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Permissions Page Placeholder'),
          ElevatedButton(
            onPressed: onFinish,
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
