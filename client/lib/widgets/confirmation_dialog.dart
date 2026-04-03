import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog({
  required BuildContext context,
  String title = "Confirm Action",
  String message = "This action cannot be undone. Are you sure?",
  String confirmText = "Delete",
  String cancelText = "Cancel",
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // user MUST choose
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        actions: [
          /// Cancel
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),

          /// Confirm (Danger)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );

  return result ?? false;
}