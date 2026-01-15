import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


//  call back after signing in
class SpotifyAuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // From Spotify Developer Dashboard
  final String _clientId = '62441da74db642539261e0673a43df21';
  final String _redirectUri = 'com.swipify.app://oauthredirect';
  final List<String> _scopes = [
    'playlist-read-private',
    'playlist-modify-private',
    'playlist-modify-public',
    'user-library-read',
  ];

  Future<bool> signInWithSpotify() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              _clientId,
              _redirectUri,
              serviceConfiguration: const AuthorizationServiceConfiguration(
                authorizationEndpoint: 'https://accounts.spotify.com/authorize',
                tokenEndpoint: 'https://accounts.spotify.com/api/token',
              ),
              scopes: _scopes,
            ),
          );

      if (result == null) return false;

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
}


