import 'package:flutter/material.dart';
import 'package:swipify/services/spotify_api_services.dart';

class SongPage extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const SongPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  List<dynamic> tracks = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadTracks();
  }

  Future<void> loadTracks() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await SpotifyApiService.getPlaylistTracks(
        widget.playlistId,
      );

      if (!mounted) return;

      setState(() {
        tracks = result ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Failed to load tracks: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.playlistName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF214f4b),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loadTracks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : tracks.isEmpty
          ? const Center(child: Text('No tracks in this playlist'))
          : Column(
              children: [
                // This is your "Total Songs" header — clean and lowkey
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 24, right: 20, left: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Total Songs: ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${tracks.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadTracks,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final trackItem = tracks[index];
                        final track =
                            trackItem['track'] as Map<String, dynamic>?;

                        if (track == null) {
                          return const Card(
                            child: ListTile(title: Text('Invalid track')),
                          );
                        }

                        final name =
                            track['name'] as String? ?? 'Unknown Track';
                        final artists =
                            (track['artists'] as List<dynamic>?)
                                ?.map((a) => a['name'] as String)
                                .join(', ') ??
                            'Unknown Artist';
                        final albumName =
                            track['album']?['name'] as String? ?? '';
                        final imageUrl =
                            track['album']?['images'] != null &&
                                (track['album']['images'] as List).isNotEmpty
                            ? track['album']['images'][0]['url'] as String
                            : null;

                        return Card(
                          child: ListTile(
                            leading: imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.music_note),
                                    ),
                                  )
                                : const Icon(Icons.music_note, size: 56),
                            title: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('$artists • $albumName'),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    shape: RoundedRectangleBorder(),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/swipe',
                      arguments: {
                        'playlistId': widget.playlistId,
                        'playlistName': widget.playlistName,
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Start Swiping!',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
