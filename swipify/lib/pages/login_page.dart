import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipify/providers/spotify_auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // listen for loading changes
    final auth = context.watch<SpotifyAuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF214f4b),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // logo
            SizedBox(
              width: 220,
              height: 220,
              child: Image.asset(
                'assets/images/swipify.jpg',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      // use provider's login()
                      final success =
                          await context.read<SpotifyAuthProvider>().login();

                      if (!mounted) return;

                      if (success) {
                        Navigator.pushReplacementNamed(context, '/playlists');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Spotify login failed'),
                          ),
                        );
                      }
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (auth.isLoading) ...[
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else ...[
                    const SizedBox(width: 12),
                  ],
                  const Text(
                    'Login With Spotify',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
