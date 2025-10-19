import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

/// Simple service to talk to a local LM Studio (OpenAI-compatible) server.
class LlmService {
  final String baseUrl; // e.g. http://127.0.0.1:1234
  final String model; // e.g. qwen/qwen3-1.7b
  final String? apiKey; // Not needed for local, placeholder for remote

  LlmService({required this.baseUrl, required this.model, this.apiKey});

  Future<Message> createChatCompletion(List<Message> history) async {
    final uri = Uri.parse('$baseUrl/v1/chat/completions');
    final payload = {
      'model': model,
      'messages': history
          .map((m) => {'role': _mapRole(m.role), 'content': m.content})
          .toList(),
      'temperature': 0.7,
      'stream': false,
    };

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (apiKey != null && apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 200) {
      throw Exception('LLM error ${resp.statusCode}: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    final content = choices != null && choices.isNotEmpty
        ? (choices.first['message']['content'] ?? '').toString()
        : '';

    // Sanitize model output: strip hidden "think" sections if present
    final cleaned = _stripThinkSections(content).trim();
    return Message(role: MessageRole.assistant, content: cleaned);
  }

  String _mapRole(MessageRole role) => switch (role) {
    MessageRole.system => 'system',
    MessageRole.user => 'user',
    MessageRole.assistant => 'assistant',
  };

  // Removes any <think> ... </think> blocks from the response, case-insensitive and multiline
  String _stripThinkSections(String content) {
    // Remove full <think>...</think> blocks
    final thinkBlock = RegExp(
      r'<\s*think\s*>.*?<\s*/\s*think\s*>',
      caseSensitive: false,
      dotAll: true,
    );
    var out = content.replaceAll(thinkBlock, '');
    // Remove any stray opening/closing think tags just in case
    out = out.replaceAll(
      RegExp(r'<\s*/?\s*think\s*>', caseSensitive: false),
      '',
    );
    return out;
  }
}
