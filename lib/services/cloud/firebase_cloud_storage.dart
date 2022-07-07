import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todos/services/cloud/cloud_note.dart';
import 'package:todos/services/cloud/cloud_storage_constants.dart';
import 'package:todos/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("notes");

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  // singleton instance
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Future<void> deleteNote({
    required String noteId,
  }) async {
    try {
      await notes.doc(noteId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String noteId,
    required String text,
  }) async {
    try {
      await notes.doc(noteId).update({
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  void createNewNote({
    required String ownerUserId,
    required String text,
  }) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: text,
    });
  }

  Future<Iterable<CloudNote>> getNotesForUser(
      {required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote(
                documentId: doc.id,
                text: doc.data()[textFieldName],
                ownerUserId: doc.data()[ownerUserIdFieldName],
              ),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }
}
