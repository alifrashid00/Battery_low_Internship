// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  author: json['by'] as String?,
  timestamp: (json['time'] as num).toInt(),
  url: json['url'] as String?,
  text: json['text'] as String?,
  score: (json['score'] as num?)?.toInt(),
  descendants: (json['descendants'] as num?)?.toInt(),
);

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'by': instance.author,
  'time': instance.timestamp,
  'url': instance.url,
  'text': instance.text,
  'score': instance.score,
  'descendants': instance.descendants,
};
