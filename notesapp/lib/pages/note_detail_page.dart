import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/settings_provider.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteDetailPage({super.key, this.noteId});

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Note? _currentNote;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeNote();
  }

  void _initializeNote() {
    if (widget.noteId != null) {
      _currentNote = ref
          .read(notesProvider.notifier)
          .getNoteById(widget.noteId!);
      _titleController = TextEditingController(text: _currentNote?.title ?? '');
      _contentController = TextEditingController(
        text: _currentNote?.content ?? '',
      );
    } else {
      _currentNote = null;
      _titleController = TextEditingController();
      _contentController = TextEditingController();
      _isEditing = true;
    }

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_currentNote != null) {
      final hasChanges =
          _titleController.text != _currentNote!.title ||
          _contentController.text != _currentNote!.content;
      if (hasChanges != _hasChanges) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    } else {
      // For new notes, consider it changed if there's any content
      final hasChanges =
          _titleController.text.isNotEmpty ||
          _contentController.text.isNotEmpty;
      if (hasChanges != _hasChanges) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isNewNote = widget.noteId == null;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasChanges) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isNewNote ? 'New Note' : 'Edit Note',
            style: TextStyle(fontSize: settings.fontSize + 4),
          ),
          actions: [
            if (!isNewNote && !_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              ),
            if (_isEditing)
              IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
            if (!isNewNote)
              PopupMenuButton(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                enabled: _isEditing,
                style: TextStyle(
                  fontSize: settings.fontSize + 6,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Note title',
                  hintStyle: TextStyle(fontSize: settings.fontSize + 6),
                  border: _isEditing
                      ? const UnderlineInputBorder()
                      : InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  enabled: _isEditing,
                  style: TextStyle(fontSize: settings.fontSize),
                  decoration: InputDecoration(
                    hintText: 'Start typing your note...',
                    hintStyle: TextStyle(fontSize: settings.fontSize),
                    border: _isEditing
                        ? const OutlineInputBorder()
                        : InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              if (_currentNote != null && !_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Text(
                        'Last updated: ${_formatDate(_currentNote!.updatedAt)}',
                        style: TextStyle(
                          fontSize: settings.fontSize - 2,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note cannot be empty')));
      return;
    }

    final now = DateTime.now();

    if (widget.noteId == null) {
      // Create new note
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      ref.read(notesProvider.notifier).addNote(newNote);
      context.pop();
    } else {
      // Update existing note
      final updatedNote = _currentNote!.copyWith(
        title: title,
        content: content,
        updatedAt: now,
      );
      ref.read(notesProvider.notifier).updateNote(updatedNote);
      _currentNote = updatedNote;
      setState(() {
        _isEditing = false;
        _hasChanges = false;
      });
    }
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes. Do you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Editing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text(
          'Are you sure you want to delete "${_currentNote!.title.isEmpty ? 'Untitled' : _currentNote!.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(_currentNote!.id);
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
