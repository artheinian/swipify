import 'package:flutter/material.dart';

class SpotifyCallbackPage extends StatelessWidget {
  const SpotifyCallbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base; // full current URL
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    return Scaffold(
      appBar: AppBar(title: const Text('Spotify Callback')),
      body: Center(child: Text('Authorization code: $code\nState: $state')),
    );
  }
}
