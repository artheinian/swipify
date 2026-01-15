import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyAuthServices {
  // Now loaded from .env (no more hard-coded secrets!)
  static final String _clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
  static final String _redirectUri = dotenv.env['SPOTIFY_REDIRECT_URI']!;

  // Scopes = permissions your app needs
  static const List<String> _scopes = [
    'playlist-read-private',
    'playlist-modify-private',
    'playlist-modify-public',
    'user-read-email',
    'user-read-private',
  ];

  static const String _discoveryUrl =
      'https://accounts.spotify.com/.well-known/openid-configuration';

  // single shared instances
  static final FlutterAppAuth _appAuth = const FlutterAppAuth();
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  static Future<bool> login() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              _clientId,
              _redirectUri,
              discoveryUrl: _discoveryUrl,
              scopes: _scopes,
            ),
          );

      if (result == null) {
        return false;
      }

      // Save tokens for later API calls
      await _secureStorage.write(
        key: 'spotify_access_token',
        value: result.accessToken,
      );
      await _secureStorage.write(
        key: 'spotify_refresh_token',
        value: result.refreshToken,
      );

      return true;
    } catch (e) {
      print('Spotify sign-in error: $e');
      return false;
    }
  }

  static Future<String?> getAccessToken() {
    return _secureStorage.read(key: 'spotify_access_token');
  }

  // Bonus: simple logout (optional but nice to have)
  static Future<void> logout() async {
    await _secureStorage.delete(key: 'spotify_access_token');
    await _secureStorage.delete(key: 'spotify_refresh_token');
  }


}
