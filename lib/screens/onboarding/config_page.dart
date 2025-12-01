import 'package:flutter/material.dart';

class OnboardingConfigPage extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingConfigPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Config Page Placeholder'),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
