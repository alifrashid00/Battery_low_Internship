import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]) {
    _loadNotes();
  }

  static const String _notesKey = 'notes';

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_notesKey);
    if (notesJson != null) {
      final List<dynamic> notesList = json.decode(notesJson);
      state = notesList.map((json) => Note.fromJson(json)).toList();
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(state.map((note) => note.toJson()).toList());
    await prefs.setString(_notesKey, notesJson);
  }

  void addNote(Note note) {
    state = [note, ...state];
    _saveNotes();
  }

  void updateNote(Note updatedNote) {
    state = state.map((note) {
      return note.id == updatedNote.id ? updatedNote : note;
    }).toList();
    _saveNotes();
  }

  void deleteNote(String id) {
    state = state.where((note) => note.id != id).toList();
    _saveNotes();
  }

  Note? getNoteById(String id) {
    try {
      return state.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier();
});
