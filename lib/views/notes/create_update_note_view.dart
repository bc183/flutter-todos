import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todos/services/auth/auth_service.dart';
import 'package:todos/services/cloud/cloud_note.dart';
import 'package:todos/services/cloud/firebase_cloud_storage.dart';
import 'package:todos/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:todos/utils/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _firebaseCloudStorage;
  late final TextEditingController _textController;

  @override
  void initState() {
    _firebaseCloudStorage = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _firebaseCloudStorage.updateNote(
      noteId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    // if note is already in route args, get it and return
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _firebaseCloudStorage.createNewNote(
      ownerUserId: userId,
      text: '',
    );
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _firebaseCloudStorage.deleteNote(noteId: note.documentId);
    }
  }

  void _saveNote() async {
    final note = _note;
    final text = _textController.text;

    // if text is same dont update the note.
    if (note != null && text == note.text) {
      return;
    }

    if (note != null && text.isNotEmpty) {
      await _firebaseCloudStorage.updateNote(
        noteId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNote();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;

              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
                return;
              }

              Share.share(text);
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your note...',
                  ),
                ),
              );
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
