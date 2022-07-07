import 'package:flutter/material.dart';
import 'package:todos/utils/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Sharing",
    content: "You cannot share empty notes.",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
