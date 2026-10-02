import 'package:flutter/material.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const NotesPage(),
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
  final List<String> _notes = [];

  // Индекс редактируемой заметки (null — режим добавления)
  int? _editingIndex;

  bool get _isEditing => _editingIndex != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Сохранение новой заметки или обновление существующей
  void _saveNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (_isEditing) {
        _notes[_editingIndex!] = text;
        _editingIndex = null;
      } else {
        _notes.add(text);
      }
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  // Переход в режим редактирования
  void _startEditing(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text = _notes[index];
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  // Отмена редактирования
  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  // Удаление заметки
  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);

      if (_editingIndex != null) {
        if (_editingIndex == index) {
          // Удалили заметку, которую редактировали
          _editingIndex = null;
          _controller.clear();
        } else if (_editingIndex! > index) {
          // Сдвиг индекса после удаления элемента выше
          _editingIndex = _editingIndex! - 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                labelText: _isEditing ? 'Редактирование заметки' : 'Новая заметка',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _saveNote,
                    child: Text(_isEditing ? 'Обновить' : 'Сохранить'),
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _cancelEditing,
                    child: const Text('Отмена'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(child: Text('Заметок пока нет'))
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final isSelected = _editingIndex == index;
                        return Card(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          child: ListTile(
                            title: Text(_notes[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Редактировать',
                                  onPressed: () => _startEditing(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Удалить',
                                  onPressed: () => _deleteNote(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}