import 'package:flutter/material.dart';
import 'package:todos/utils/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content:
        'We have now sent you a password reset link. Please, check your mail for more information.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
