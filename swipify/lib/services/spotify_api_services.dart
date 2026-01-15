import 'dart:convert';
import 'package:http/http.dart' as http;
import 'spotify_auth_services.dart';

class SpotifyApiService {
  // Get current user's display name (or Spotify ID if no display name)
  static Future<String?> getCurrentUserDisplayName() async {
    final token = await SpotifyAuthServices.getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? data['id'];
    } else if (response.statusCode == 401) {
      print('Token expired');
      return null;
    } else {
      print('Error fetching user: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  // Get user's playlists
  static Future<List<dynamic>?> getUserPlaylists({
    int limit = 50,
    int offset = 0,
  }) async {
    // need the token so we can access the users playlsits
    final token = await SpotifyAuthServices.getAccessToken();
    if (token == null) return null;

    final url = Uri.parse(
      'https://api.spotify.com/v1/me/playlists?limit=$limit&offset=$offset',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] as List<dynamic>;
    } else {
      print('Playlists error ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  // Get full user profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final token = await SpotifyAuthServices.getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      print('Profile error ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  // Get playlist tracks
  static Future<List<dynamic>?> getPlaylistTracks(String playlistId) async {
    final token = await SpotifyAuthServices.getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(
        'https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=100',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] as List<dynamic>;
    } else {
      print('Error loading tracks ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  // Remove a song from your playlist
  static Future<bool> removeTracksFromPlaylist(
    String playlistId,
    List<String> trackUris,
  ) async {
    final token = await SpotifyAuthServices.getAccessToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tracks': trackUris.map((uri) => {'uri': uri}).toList(),
      }),
    );

    return response.statusCode == 200;
  }
  
}
