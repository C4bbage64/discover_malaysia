import 'package:flutter/material.dart';
import '../errors/app_exception.dart';

/// UI helper utilities for consistent error display and common patterns
class UIHelpers {
  UIHelpers._();

  // ============ Snackbar Helpers ============

  /// Show an error snackbar with the exception message
  static void showErrorSnackBar(BuildContext context, AppException exception) {
    showSnackBar(
      context,
      message: exception.message,
      isError: true,
    );
  }

  /// Show a generic error snackbar
  static void showErrorMessage(BuildContext context, String message) {
    showSnackBar(context, message: message, isError: true);
  }

  /// Show a success snackbar
  static void showSuccessMessage(BuildContext context, String message) {
    showSnackBar(context, message: message, isError: false);
  }

  /// Show a snackbar with customizable style
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ============ Dialog Helpers ============

  /// Show an error dialog with optional retry action
  static Future<bool?> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? retryLabel,
    VoidCallback? onRetry,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, true);
                onRetry();
              },
              child: Text(retryLabel ?? 'Retry'),
            ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ============ Loading Helpers ============

  /// Show a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message ?? 'Please wait...')),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
