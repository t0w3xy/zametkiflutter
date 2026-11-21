part of 'notes_cubit.dart';

@immutable
class Note {
  final int id;
  final String text;
  final bool isImportant;

  const Note({
    required this.id,
    required this.text,
    this.isImportant = false,
  });

  Note copyWith({String? text, bool? isImportant}) {
    return Note(
      id: id,
      text: text ?? this.text,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}

@immutable
class NotesState {
  final List<Note> notes;
  final int? editingId;

  const NotesState({this.notes = const [], this.editingId});

  bool get isEditing => editingId != null;
}
