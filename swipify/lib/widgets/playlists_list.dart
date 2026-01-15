import 'package:flutter/material.dart';
import 'package:swipify/pages/song_page.dart';

class PlaylistsList extends StatelessWidget {
  final List<dynamic> playlists;

  const PlaylistsList({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.playlist_remove),
          title: Text('No playlists found'),
        ),
      );
    }

    return Column(
      children: playlists.map((p) {
        final hasImage = p['images'] != null && p['images'].isNotEmpty;
        final String playlistId = p['id'] as String;
        final String playlistName = p['name'] as String;

        return Card(
          child: ListTile(
            leading: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p['images'][0]['url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.playlist_play, size: 50),
            title: Text(
              playlistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${p['tracks']['total']} tracks • ${p['owner']['display_name'] ?? 'You'}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongPage(
                    playlistId: playlistId,
                    playlistName: playlistName,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
