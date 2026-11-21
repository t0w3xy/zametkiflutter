part of 'notes_cubit.dart';

@immutable
class Note {
  final int id;
  final String text;

  const Note({required this.id, required this.text});
}

@immutable
class NotesState {
  final List<Note> notes;
  final int? editingId;

  const NotesState({this.notes = const [], this.editingId});

  bool get isEditing => editingId != null;
}
