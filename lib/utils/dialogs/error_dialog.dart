import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:todos/utils/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: "An error has occurred",
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
