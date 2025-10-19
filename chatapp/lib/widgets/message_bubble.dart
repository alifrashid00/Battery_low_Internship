import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool animateOnBuild;
  const MessageBubble({
    super.key,
    required this.message,
    this.animateOnBuild = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    final bubble = Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isUser
            ? SelectableText(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : MarkdownBody(
                data: message.content,
                selectable: true,
                builders: {'code': CodeElementBuilder(theme)},
                styleSheet: MarkdownStyleSheet(
                  p: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    color: theme.colorScheme.onSurface,
                  ),
                  h1: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  code: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  codeblockPadding: const EdgeInsets.all(12),
                  blockquoteDecoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 4,
                      ),
                    ),
                  ),
                  listBullet: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
      ),
    );

    if (!animateOnBuild) return bubble;

    // Slide in from left (assistant) or right (user) with fade
    final beginOffset = isUser ? const Offset(0.2, 0) : const Offset(-0.2, 0);
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: beginOffset, end: Offset.zero),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final opacity = 1.0 - (value.dx.abs() * 3).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(value.dx * 40, 0),
            child: child,
          ),
        );
      },
      child: bubble,
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  final ThemeData theme;

  CodeElementBuilder(this.theme);

  @override
  Widget? visitElementAfter(element, preferredStyle) {
    final language =
        element.attributes['class']?.replaceFirst('language-', '') ?? '';
    final code = element.textContent;

    if (language.isNotEmpty && language != 'text') {
      // Use syntax highlighting for known languages
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language label
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(
                language.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Highlighted code
            HighlightView(
              code,
              language: language,
              theme: _getCodeTheme(theme),
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // Fallback for inline code or unknown languages
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        code,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
    );
  }

  Map<String, TextStyle> _getCodeTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.colorScheme.surfaceContainerHigh;

    return {
      'root': TextStyle(
        backgroundColor: bgColor,
        color: theme.colorScheme.onSurface,
      ),
      'keyword': TextStyle(
        color: isDark ? const Color(0xFF569CD6) : const Color(0xFF0000FF),
        fontWeight: FontWeight.bold,
      ),
      'string': TextStyle(
        color: isDark ? const Color(0xFFCE9178) : const Color(0xFF008000),
      ),
      'comment': TextStyle(
        color: isDark ? const Color(0xFF6A9955) : const Color(0xFF008000),
        fontStyle: FontStyle.italic,
      ),
      'number': TextStyle(
        color: isDark ? const Color(0xFFB5CEA8) : const Color(0xFF09885A),
      ),
      'built_in': TextStyle(
        color: isDark ? const Color(0xFF4EC9B0) : const Color(0xFF267F99),
      ),
      'literal': TextStyle(
        color: isDark ? const Color(0xFF569CD6) : const Color(0xFF0000FF),
      ),
      'class': TextStyle(
        color: isDark ? const Color(0xFF4EC9B0) : const Color(0xFF267F99),
      ),
      'function': TextStyle(
        color: isDark ? const Color(0xFFDCDCAA) : const Color(0xFF795E26),
      ),
      'variable': TextStyle(color: theme.colorScheme.onSurface),
    };
  }
}
