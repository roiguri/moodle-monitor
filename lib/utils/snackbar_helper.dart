import 'package:flutter/material.dart';

/// Utility class for showing consistent snackbars throughout the app
class SnackbarHelper {
  /// Show an error snackbar with red background
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      textColor: Theme.of(context).colorScheme.onError,
      icon: Icons.error_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show a warning snackbar with orange background
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange[800], // Darker orange for better contrast
      textColor: Colors.white,
      icon: Icons.warning_amber_rounded,
      duration: duration,
      action: action,
    );
  }

  /// Show a success snackbar with green background
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.green[700],
      textColor: Colors.white,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  /// Show an info snackbar with primary color background
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimary,
      icon: Icons.info_outline,
      duration: duration,
      action: action,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color? backgroundColor,
    required Color textColor,
    required IconData icon,
    required Duration duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    action.onPressed();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    action.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }
}
