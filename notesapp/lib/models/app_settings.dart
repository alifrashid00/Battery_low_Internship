import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final double fontSize;

  const AppSettings({this.themeMode = ThemeMode.system, this.fontSize = 16.0});

  AppSettings copyWith({ThemeMode? themeMode, double? fontSize}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.name, 'fontSize': fontSize};
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
    );
  }

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, fontSize: $fontSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode => Object.hash(themeMode, fontSize);
}
