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

  void _onSavePressed() {
    if (_controller.text.trim().isEmpty) return;
    context.read<NotesCubit>().saveNote(_controller.text);
    _controller.clear();
    FocusScope.of(context).unfocus();
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
                      ? const Center(child: Text('Заметок пока нет'))
                      : ListView.builder(
                          itemCount: state.notes.length,
                          itemBuilder: (context, index) {
                            final note = state.notes[index];
                            final isSelected = state.editingId == note.id;
                            return Card(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : null,
                              child: ListTile(
                                title: Text(note.text),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Редактировать',
                                      onPressed: () => context
                                          .read<NotesCubit>()
                                          .startEdit(note.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Удалить',
                                      onPressed: () => context
                                          .read<NotesCubit>()
                                          .deleteNote(note.id),
                                    ),
                                  ],
                                ),
                              ),
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