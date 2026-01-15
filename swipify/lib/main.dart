import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:swipify/pages/login_page.dart';
import 'package:swipify/pages/playlists_page.dart';
import 'package:swipify/pages/song_page.dart';
import 'package:swipify/pages/swipe_page.dart';
import 'package:swipify/services/spotify_auth_services.dart';
import 'package:swipify/providers/spotify_auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(
    fileName: 'assets/.env', // loads your .env from assets root
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => SpotifyAuthProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/playlists':
            return MaterialPageRoute(
              builder: (_) => FutureBuilder<bool>(
                future: SpotifyAuthServices.getAccessToken().then(
                  (token) => token != null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final isLoggedIn = snapshot.data ?? false;

                  if (!isLoggedIn) {
                    return const LoginPage(); // redirect to login
                  }

                  return const PlaylistsPage();
                },
              ),
            );

          case '/song':
            final args = settings.arguments as Map<String, dynamic>?;

            if (args == null || args['playlistId'] == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Error: No playlist selected')),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (_) => SongPage(
                playlistId: args['playlistId'] as String,
                playlistName: args['playlistName'] as String? ?? 'Playlist',
              ),
            );

          case '/swipe':
            final args = settings.arguments as Map<String, dynamic>?;

            if (args == null || args['playlistId'] == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(
                    child: Text('Error: No playlist selected for swiping'),
                  ),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (_) => SwipePage(
                playlistId: args['playlistId'] as String,
                playlistName: args['playlistName'] as String? ?? 'Swiping',
              ),
            );

          default:
            print(settings.name);
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404 – Page not found')),
              ),
            );
        }
      },
    );
  }
}
