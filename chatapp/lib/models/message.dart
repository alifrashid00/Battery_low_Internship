import 'package:uuid/uuid.dart';

/// Role of the message relative to the LLM API
enum MessageRole { system, user, assistant }

final _uuid = const Uuid();

class Message {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final bool isStreaming; // indicates partial/streaming content

  Message({
    String? id,
    required this.role,
    required this.content,
    DateTime? createdAt,
    this.isStreaming = false,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now();

  Message copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? createdAt,
    bool? isStreaming,
  }) => Message(
    id: id ?? this.id,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    isStreaming: isStreaming ?? this.isStreaming,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.name,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isStreaming': isStreaming,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String?,
    role: MessageRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => MessageRole.user,
    ),
    content: json['content'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    isStreaming: json['isStreaming'] ?? false,
  );
}
