import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/notes_cubit.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesCubit(),
      child: MaterialApp(
        title: 'Заметки',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const NotesPage(),
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSavePressed() {
    if (_controller.text.trim().isEmpty) return;
    context.read<NotesCubit>().saveNote(_controller.text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  // Обычное нажатие — просмотр полного текста
  void _openNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteViewPage(note: note)),
    );
  }

  // Двойное нажатие — отметить как важную
  void _markImportant(Note note) {
    if (note.isImportant) {
      _showMessage('Заметка уже отмечена как важная');
      return;
    }
    context.read<NotesCubit>().markImportant(note.id);
    _showMessage('Заметка отмечена как важная ⭐️');
  }

  // Свайп вправо — вернуть обычный статус
  void _restoreNote(Note note) {
    if (!note.isImportant) {
      _showMessage('Заметка и так обычная');
      return;
    }
    context.read<NotesCubit>().restoreNote(note.id);
    _showMessage('Обычный статус заметки восстановлен');
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, bool isSelected) {
    final cubit = context.read<NotesCubit>();

    Color? cardColor;
    if (isSelected) {
      cardColor = Theme.of(context).colorScheme.primaryContainer;
    } else if (note.isImportant) {
      cardColor = Colors.amber.shade100;
    }

    return Dismissible(
      key: ValueKey(note.id),
      // Свайп вправо — фон «восстановить»
      background: _swipeBackground(
        alignment: Alignment.centerLeft,
        color: Colors.green,
        icon: Icons.restore,
        label: 'Обычная',
      ),
      // Свайп влево — фон «удалить»
      secondaryBackground: _swipeBackground(
        alignment: Alignment.centerRight,
        color: Colors.red,
        icon: Icons.delete,
        label: 'Удалить',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Вправо: меняем статус, но карточку из списка не убираем
          _restoreNote(note);
          return false;
        }
        return true; // Влево: удаляем
      },
      onDismissed: (_) => cubit.deleteNote(note.id),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: note.isImportant ? Colors.amber.shade700 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openNote(note),
          onDoubleTap: () => _markImportant(note),
          onLongPress: () => cubit.startEdit(note.id),
          child: ListTile(
            leading: note.isImportant
                ? const Text('⭐️', style: TextStyle(fontSize: 22))
                : null,
            title: Text(
              note.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Редактировать',
                  onPressed: () => cubit.startEdit(note.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Удалить',
                  onPressed: () => cubit.deleteNote(note.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<NotesCubit, NotesState>(
          listenWhen: (prev, curr) => prev.editingId != curr.editingId,
          listener: (context, state) {
            if (state.editingId == null) {
              _controller.clear();
            } else {
              final note =
                  state.notes.firstWhere((n) => n.id == state.editingId);
              _controller.text = note.text;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: state.isEditing
                        ? 'Редактирование заметки'
                        : 'Новая заметка',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _onSavePressed,
                        child: Text(state.isEditing ? 'Обновить' : 'Сохранить'),
                      ),
                    ),
                    if (state.isEditing) ...[
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => context.read<NotesCubit>().cancelEdit(),
                        child: const Text('Отмена'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.notes.isEmpty
                      ? const Center(
                          child: Text(
                            'Заметок пока нет\n\n'
                            'Нажатие — просмотр\n'
                            'Двойное нажатие — важная ⭐️\n'
                            'Долгое нажатие — редактирование\n'
                            'Свайп влево — удалить\n'
                            'Свайп вправо — снять статус «важная»',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.notes.length,
                          itemBuilder: (context, index) {
                            final note = state.notes[index];
                            return _buildNoteCard(
                              note,
                              state.editingId == note.id,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Экран просмотра полного текста заметки
class NoteViewPage extends StatelessWidget {
  final Note note;

  const NoteViewPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.isImportant ? 'Заметка ⭐️' : 'Заметка'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: SelectableText(
            note.text,
            style: const TextStyle(fontSize: 18, height: 1.4),
          ),
        ),
      ),
    );
  }
}
