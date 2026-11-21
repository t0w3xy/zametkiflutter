import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  int _nextId = 0;

  NotesCubit() : super(const NotesState());

  // Добавление новой заметки или обновление редактируемой
  void saveNote(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final editingId = state.editingId;
    if (editingId != null) {
      // copyWith сохраняет статус «важная» при редактировании
      emit(NotesState(
        notes: [
          for (final note in state.notes)
            note.id == editingId ? note.copyWith(text: trimmed) : note,
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

  // Двойное нажатие — отметить как важную
  void markImportant(int id) => _setImportant(id, true);

  // Свайп вправо — вернуть обычный статус
  void restoreNote(int id) => _setImportant(id, false);

  void _setImportant(int id, bool value) {
    emit(NotesState(
      notes: [
        for (final note in state.notes)
          note.id == id ? note.copyWith(isImportant: value) : note,
      ],
      editingId: state.editingId,
    ));
  }
}
