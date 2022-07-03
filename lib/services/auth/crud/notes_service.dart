import 'dart:async';

import 'package:flutter/cupertino.dart';
import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart"
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import "package:path/path.dart" show join;

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  static final NotesService _shared = NotesService._sharedInstance();

  NotesService._sharedInstance();

  factory NotesService() => _shared;

  List<DatabaseNote> _notes = [];

  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> _cachedNotes() async {
    final allNotes = await getAllNotes();

    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatedCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedwithCloudColumn: 0,
    });

    if (updatedCount == 0) {
      throw CouldNotUpdateNote();
    }

    final updatedNote = await getNote(id: note.id);

    _notes.removeWhere((n) => n.id == note.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(noteTable);

    return notes.map((n) => DatabaseNote.fromRow(n));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final note = await db.query(
      noteTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );

    if (note.isEmpty) {
      throw CouldNotFindNote();
    }

    final savedNote = DatabaseNote.fromRow(note.first);

    _notes.removeWhere((note) => note.id == id);
    _notes.add(savedNote);
    _notesStreamController.add(_notes);

    return savedNote;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(noteTable);

    _notes.clear();
    _notesStreamController.add(_notes);
    return deletedCount;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }

    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> createNote({
    required String text,
    required DatabaseUser user,
  }) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: user.email);

    if (dbUser != user) {
      throw CouldNotFindUserException();
    }

    final noteId = await db.insert(noteTable, {
      userIdColumn: user.id,
      textColumn: text,
      isSyncedwithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: user.id,
      text: text,
      isSyncedwithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUserException();
    }

    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email.toLowerCase(),
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      userTable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpenException();
    }

    return db;
  }

  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpenException();
    }

    await db.close();
    _db = null;
  }

  Future<void> _ensureDBIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // creating the user table
      await db.execute(createUserTable);

      // creating the user table
      await db.execute(createNoteTable);

      // cache notes
      await _cachedNotes();
    } on MissingPlatformDirectoryException catch (_) {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return 'Person, ID = $id, email = $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedwithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedwithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedwithCloud =
            (map[isSyncedwithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return 'Note, ID = $id, userId = $userId, isSyncedwithCloud = $isSyncedwithCloud';
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedwithCloudColumn = "is_synced_with_cloud";

const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user" (
          "id" INTEGER NOT NULL,
          "email" TEXT NOT NULL UNIQUE,
          PRIMARY KEY ("id" AUTOINCREMENT)
        );
      ''';

const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
          "id" INTEGER NOT NULL,
          "user_id" INTEGER NOT NULL,
          "text" TEXT,
          "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY ("user_id") REFERENCES "user"("id"),
          PRIMARY KEY ("id" AUTOINCREMENT)
        );
      ''';
