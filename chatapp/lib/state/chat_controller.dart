import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../repository/chat_repository.dart';
import '../services/llm_service.dart';

extension IterableX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class ChatState {
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final bool isLoading;
  final String? error;

  ChatState({
    required this.sessions,
    required this.activeSessionId,
    required this.isLoading,
    required this.error,
  });

  ChatState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    bool? isLoading,
    String? error,
  }) => ChatState(
    sessions: sessions ?? this.sessions,
    activeSessionId: activeSessionId ?? this.activeSessionId,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  ChatSession? get activeSession =>
      sessions
          .where((s) => s.id == activeSessionId)
          .cast<ChatSession?>()
          .firstOrNull ??
      (sessions.isNotEmpty ? sessions.first : null);

  factory ChatState.initial() => ChatState(
    sessions: const [],
    activeSessionId: null,
    isLoading: false,
    error: null,
  );
}

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository repo;
  final LlmService llm;

  ChatController(this.repo, this.llm) : super(ChatState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final sessions = await repo.loadSessions();
    if (sessions.isEmpty) {
      final s = repo.newSession();
      state = state.copyWith(sessions: [s], activeSessionId: s.id);
    } else {
      state = state.copyWith(
        sessions: sessions,
        activeSessionId: sessions.first.id,
      );
    }
  }

  Future<void> sendMessage(String content) async {
    final session = state.activeSession;
    if (session == null) return;
    final userMsg = Message(role: MessageRole.user, content: content);

    // Auto-title the chat from first user message if it's still "New Chat"
    var updatedSession = session.copyWith(
      messages: [...session.messages, userMsg],
    );
    if (session.title == 'New Chat' && session.messages.isEmpty) {
      final autoTitle = _generateTitleFromMessage(content);
      if (autoTitle.isNotEmpty) {
        updatedSession = updatedSession.copyWith(title: autoTitle);
      }
    }

    _replaceSession(updatedSession);
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reply = await llm.createChatCompletion(updatedSession.messages);
      final withReply = updatedSession.copyWith(
        messages: [...updatedSession.messages, reply],
      );
      _replaceSession(withReply);
      await repo.saveSessions(state.sessions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _replaceSession(ChatSession updated) {
    final newList = [
      for (final s in state.sessions)
        if (s.id == updated.id) updated else s,
    ];
    state = state.copyWith(sessions: newList);
  }

  Future<void> newChat() async {
    final s = repo.newSession();
    state = state.copyWith(
      sessions: [s, ...state.sessions],
      activeSessionId: s.id,
    );
    await repo.saveSessions(state.sessions);
  }

  void setActive(String id) {
    state = state.copyWith(activeSessionId: id);
  }

  // Rename functionality
  Future<void> renameSession(String sessionId, String newTitle) async {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;

    final sessionIndex = state.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final updatedSession = state.sessions[sessionIndex].copyWith(
      title: trimmed,
    );
    _replaceSession(updatedSession);
    await repo.saveSessions(state.sessions);
  }

  Future<void> renameActiveSession(String newTitle) async {
    final activeSession = state.activeSession;
    if (activeSession != null) {
      await renameSession(activeSession.id, newTitle);
    }
  }

  // Generate title from first message (first 6-8 words, max 40 chars)
  String _generateTitleFromMessage(String content) {
    final text = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) return '';

    final words = text.split(' ');
    final limitedWords = words.take(8).join(' ');

    String title = limitedWords;
    const maxLength = 40;
    if (title.length > maxLength) {
      title = title.substring(0, maxLength).trimRight();
      if (!title.endsWith('…')) {
        title = '$title…';
      }
    }

    // Capitalize first letter
    if (title.isNotEmpty) {
      title = title[0].toUpperCase() + title.substring(1);
    }

    return title;
  }
}

// Providers
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(),
);

final llmServiceProvider = Provider<LlmService>((ref) {
  // Use proxy server to avoid CORS issues in web
  // Proxy server forwards requests to LM Studio at 127.0.0.1:1234
  return LlmService(
    baseUrl: 'http://localhost:8080/proxy',
    model: 'qwen/qwen3-1.7b',
  );
});

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) {
    final repo = ref.watch(chatRepositoryProvider);
    final llm = ref.watch(llmServiceProvider);
    return ChatController(repo, llm);
  },
);
