import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/chat_controller.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  String?
  _animatedSessionId; // used to run initial entrance animation once per session

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final session = state.activeSession;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    final scheme = Theme.of(context).colorScheme;
    // Determine if we should animate all messages (first time opening a session)
    final animateInitial = session != null && session.id != _animatedSessionId;
    if (animateInitial) {
      // Mark as animated after the first frame to avoid repeated animations
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _animatedSessionId = session.id);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: session != null
              ? () => _showRenameDialog(session.id, session.title)
              : null,
          child: Text(session?.title ?? 'Chat'),
        ),
        actions: [
          if (session != null)
            IconButton(
              onPressed: () => _showRenameDialog(session.id, session.title),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Rename chat',
            ),
          IconButton(
            onPressed: () =>
                ref.read(chatControllerProvider.notifier).newChat(),
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New chat',
          ),
        ],
      ),
      drawer: _buildDrawer(state),
      body: Column(
        children: [
          // Subtle gradient backdrop for conversation area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface,
                    scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount:
                    (session?.messages.length ?? 0) + (state.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (session == null) return const SizedBox.shrink();
                  final isLoadingIndicator =
                      state.isLoading && index == session.messages.length;
                  if (isLoadingIndicator) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: TypingIndicator(),
                    );
                  }
                  final msg = session.messages[index];
                  // Animate all messages on first open, otherwise animate only the newest message
                  final animate =
                      animateInitial || index == session.messages.length - 1;
                  return MessageBubble(message: msg, animateOnBuild: animate);
                },
              ),
            ),
          ),
          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          // Elevated composer with rounded corners
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Material(
                color: scheme.surfaceContainerHighest,
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          minLines: 1,
                          maxLines: 6,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: 'Type your message…',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filled(
                        onPressed: state.isLoading ? null : _send,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(dynamic state) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Chats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final s in state.sessions)
                    ListTile(
                      title: Text(s.title),
                      selected: s.id == state.activeSessionId,
                      onTap: () {
                        Navigator.pop(context);
                        ref
                            .read(chatControllerProvider.notifier)
                            .setActive(s.id);
                      },
                      onLongPress: () => _showRenameDialog(s.id, s.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _showRenameDialog(s.id, s.title),
                        tooltip: 'Rename chat',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(chatControllerProvider.notifier).sendMessage(text);
  }

  void _showRenameDialog(String sessionId, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Chat title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _renameChat(sessionId, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _renameChat(sessionId, controller.text);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _renameChat(String sessionId, String newTitle) {
    ref
        .read(chatControllerProvider.notifier)
        .renameSession(sessionId, newTitle);
  }
}
