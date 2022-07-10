import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:todos/constants/routes.dart';
import 'package:todos/enums/menu_action.dart';
import 'package:todos/services/auth/auth_service.dart';
import 'package:todos/services/auth/bloc/auth_bloc.dart';
import 'package:todos/services/auth/bloc/auth_event.dart';
import 'package:todos/services/cloud/cloud_note.dart';
import 'package:todos/services/cloud/firebase_cloud_storage.dart';
import 'package:todos/services/crud/notes_service.dart';
import 'package:todos/utils/dialogs/logout_dialog.dart';
import 'package:todos/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _firebaseCloudStorage;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _firebaseCloudStorage = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout && mounted) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _firebaseCloudStorage.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                if (allNotes.isEmpty) {
                  return const Center(
                    child: Text("No Notes Available"),
                  );
                }
                return NotestListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _firebaseCloudStorage.deleteNote(
                        noteId: note.documentId);
                  },
                  onTap: (note) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
