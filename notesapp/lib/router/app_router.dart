import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/note_detail_page.dart';
import '../pages/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/note/:id',
      name: 'note-detail',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return NoteDetailPage(noteId: noteId);
      },
    ),
    GoRoute(
      path: '/new-note',
      name: 'new-note',
      builder: (context, state) => const NoteDetailPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
