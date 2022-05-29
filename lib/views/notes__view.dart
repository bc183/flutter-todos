import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:todos/utils/utils.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

Future<bool> openLogoutDialog(BuildContext context) async {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      }).then((value) => value ?? false);
}

class _NotesViewState extends State<NotesView> {
  void handleLogout(BuildContext context, VoidCallback cb) async {
    await Future.delayed(const Duration(seconds: 2));
    cb.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text("My Notes"),
      backgroundColor: Colors.red,
      actions: [
        PopupMenuButton<MenuAction>(onSelected: (value) async {
          switch (value) {
            case MenuAction.logout:
              final bool shouldLogout = await openLogoutDialog(context);
              if (shouldLogout) {
                await Future.delayed(const Duration(seconds: 1));

                if (!mounted) return;
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/login/", (_) => false);
              }
              break;
          }
        }, itemBuilder: (context) {
          return const [
            PopupMenuItem<MenuAction>(
                value: MenuAction.logout, child: Text("Logout"))
          ];
        })
      ],
    ));
  }
}
