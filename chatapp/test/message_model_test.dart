import 'package:flutter_test/flutter_test.dart';
import 'package:chatapp/models/message.dart';

void main() {
  test('Message serialization round trip', () {
    final original = Message(role: MessageRole.user, content: 'Hello');
    final json = original.toJson();
    final copy = Message.fromJson(json);
    expect(copy.id, original.id);
    expect(copy.role, original.role);
    expect(copy.content, original.content);
  });
}
