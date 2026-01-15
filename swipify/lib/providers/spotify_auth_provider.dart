import 'package:flutter/foundation.dart';
import 'package:swipify/services/spotify_auth_services.dart';

class SpotifyAuthProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> login() async {
    _isLoading = true;
    notifyListeners();

    final success = await SpotifyAuthServices.login();

    _isLoading = false;
    notifyListeners();

    return success;
  }
}
