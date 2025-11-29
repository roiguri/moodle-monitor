import 'package:flutter/material.dart';
import 'package:moodle_monitor/constants/app_strings.dart';

/// Type of credentials error to display
enum CredentialsErrorType {
  missing,  // No credentials configured
  invalid,  // Credentials exist but are wrong/expired
}

/// Widget displayed when credentials are not configured or invalid
/// Shows a friendly message and prompts user to go to Settings
class CredentialsRequiredView extends StatelessWidget {
  final VoidCallback? onGoToSettings;
  final CredentialsErrorType errorType;

  const CredentialsRequiredView({
    Key? key,
    this.onGoToSettings,
    this.errorType = CredentialsErrorType.missing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Choose appropriate strings based on error type
    final title = errorType == CredentialsErrorType.invalid
        ? AppStrings.credentialsExpired
        : AppStrings.credentialsRequiredTitle;
    
    final message = errorType == CredentialsErrorType.invalid
        ? AppStrings.invalidCredentials
        : AppStrings.credentialsRequiredMessage;
    
    final buttonLabel = errorType == CredentialsErrorType.invalid
        ? AppStrings.updateCredentialsButton
        : AppStrings.goToSettingsButton;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorType == CredentialsErrorType.invalid
                  ? Icons.lock_reset
                  : Icons.vpn_key_outlined,
              size: 80,
              color: errorType == CredentialsErrorType.invalid
                  ? Colors.red[400]
                  : Colors.orange[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onGoToSettings,
              icon: Icon(
                Icons.settings,
                color: errorType == CredentialsErrorType.invalid
                    ? Colors.red[600]
                    : Colors.blue[600],
              ),
              label: Text(buttonLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
                side: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
