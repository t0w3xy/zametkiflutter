import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  int _nextId = 0;

  NotesCubit() : super(const NotesState());

  void saveNote(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final editingId = state.editingId;
    if (editingId != null) {
      emit(NotesState(
        notes: [
          for (final note in state.notes)
            note.id == editingId ? Note(id: note.id, text: trimmed) : note,
        ],
      ));
    } else {
      emit(NotesState(
        notes: [...state.notes, Note(id: _nextId++, text: trimmed)],
      ));
    }
  }

  void startEdit(int id) {
    emit(NotesState(notes: state.notes, editingId: id));
  }

  void cancelEdit() {
    emit(NotesState(notes: state.notes));
  }

  void deleteNote(int id) {
    emit(NotesState(
      notes: state.notes.where((n) => n.id != id).toList(),
      editingId: state.editingId == id ? null : state.editingId,
    ));
  }
}
