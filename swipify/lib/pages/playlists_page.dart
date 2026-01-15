import 'package:flutter/material.dart';
import 'package:swipify/services/spotify_api_services.dart';
import 'package:swipify/widgets/user_profile_card.dart';
import 'package:swipify/widgets/playlists_header.dart';
import 'package:swipify/widgets/playlists_list.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  String? username;
  List<dynamic>? playlists;
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final name = await SpotifyApiService.getCurrentUserDisplayName();
      final userProfile = await SpotifyApiService.getCurrentUserProfile();
      final plist = await SpotifyApiService.getUserPlaylists(limit: 50);

      setState(() {
        profile = userProfile;
        username = name ?? 'Unknown User';
        playlists = plist;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipify'),
        backgroundColor: const Color(0xFF214f4b),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => isLoading = true);
                      loadUserData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadUserData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  UserProfileCard(
                    profile: profile,
                    username: username ?? 'Unknown User',
                  ),
                  const SizedBox(height: 24),
                  const PlaylistsHeader(),
                  const SizedBox(height: 24),
                  PlaylistsList(playlists: playlists ?? const []),
                ],
              ),
            ),
    );
  }
}
