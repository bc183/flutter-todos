import 'package:flutter/material.dart';
import 'package:todos/services/cloud/cloud_note.dart';
import 'package:todos/utils/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotestListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotestListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        if (note.text != "") {
          return ListTile(
            onTap: () {
              onTap(note);
            },
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          );
        }
        return const Text("");
      },
    );
  }
}
