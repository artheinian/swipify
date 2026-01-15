import 'package:flutter/material.dart';

class PlaylistsHeader extends StatelessWidget {
  const PlaylistsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Your Playlists!',
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.green[700],
      ),
    );
  }
}
