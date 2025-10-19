import 'package:json_annotation/json_annotation.dart';

part 'news.g.dart';

@JsonSerializable()
class News {
  final int id;
  final String title;
  @JsonKey(name: 'by')
  final String? author;
  @JsonKey(name: 'time')
  final int timestamp;
  @JsonKey(name: 'url')
  final String? url;
  final String? text;
  final int? score;
  final int? descendants;

  const News({
    required this.id,
    required this.title,
    this.author,
    required this.timestamp,
    this.url,
    this.text,
    this.score,
    this.descendants,
  });

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);
  Map<String, dynamic> toJson() => _$NewsToJson(this);

  // Helper getters for easier access
  DateTime get publishedAt =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  String get description => text ?? 'Click to read more...';
  String get content => text ?? 'No content available.';
  String get source => 'Hacker News';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is News && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
