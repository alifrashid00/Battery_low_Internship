import 'message.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<Message> messages;

  ChatSession({
    String? id,
    required this.title,
    DateTime? createdAt,
    List<Message>? messages,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now(),
       messages = messages ?? const [];

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<Message>? messages,
  }) => ChatSession(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    messages: messages ?? this.messages,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String?,
    title: json['title'] ?? 'Chat',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    messages: (json['messages'] as List<dynamic>? ?? [])
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
