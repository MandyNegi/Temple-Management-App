import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(BuildContext context,
    {required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel'}) {
  return showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(cancelText)),
        ElevatedButton(onPressed: () => Navigator.pop(c, true), child: Text(confirmText)),
      ],
    ),
  );
}

Future<void> showInfoDialog(BuildContext context,
    {required String title, required String content, String okText = 'OK'}) {
  return showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(c), child: Text(okText)),
      ],
    ),
  );
}
