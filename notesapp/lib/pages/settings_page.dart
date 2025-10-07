import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: settings.fontSize + 4),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette),
                      const SizedBox(width: 8),
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: settings.fontSize + 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: settings.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: Text(
                          'System',
                          style: TextStyle(fontSize: settings.fontSize),
                        ),
                        subtitle: Text(
                          'Follow system theme',
                          style: TextStyle(fontSize: settings.fontSize - 2),
                        ),
                        value: ThemeMode.system,
                        groupValue: settings.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateThemeMode(value);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text(
                          'Light',
                          style: TextStyle(fontSize: settings.fontSize),
                        ),
                        subtitle: Text(
                          'Light theme',
                          style: TextStyle(fontSize: settings.fontSize - 2),
                        ),
                        value: ThemeMode.light,
                        groupValue: settings.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateThemeMode(value);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text(
                          'Dark',
                          style: TextStyle(fontSize: settings.fontSize),
                        ),
                        subtitle: Text(
                          'Dark theme',
                          style: TextStyle(fontSize: settings.fontSize - 2),
                        ),
                        value: ThemeMode.dark,
                        groupValue: settings.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateThemeMode(value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Font Size Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_fields),
                      const SizedBox(width: 8),
                      Text(
                        'Text',
                        style: TextStyle(
                          fontSize: settings.fontSize + 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Font Size',
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${settings.fontSize.toInt()}',
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: settings.fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 12,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateFontSize(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This is how your text will look.',
                      style: TextStyle(fontSize: settings.fontSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: settings.fontSize + 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Notes App',
                    style: TextStyle(
                      fontSize: settings.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A simple note-taking app built with Flutter',
                    style: TextStyle(
                      fontSize: settings.fontSize - 2,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: settings.fontSize - 2,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
