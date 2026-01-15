import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../services/spotify_api_services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SwipePage extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const SwipePage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with TickerProviderStateMixin {
  // https://pub.dev/packages/flutter_card_swiper Using this build the swipe
  List<dynamic> tracks = [];
  final List<String> _tracksToRemove = [];

  bool isLoading = true;
  bool _finished = false;

  final CardSwiperController _controller = CardSwiperController();

  late AnimationController _animationController;
  late Animation<double> _keepAnimation;
  late Animation<double> _removeAnimation;

  String _currentAction = '';
  double _swipeProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _keepAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _removeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadTracks();
  }

  Future<void> _openAndPlayTrack(Map<String, dynamic> track) async {
    final String trackId = track['id'] as String;

    // 1) Try Spotify app deep link – this is what should auto-play
    final String appUri = 'spotify:track:$trackId';

    if (await canLaunchUrlString(appUri)) {
      await launchUrlString(
        appUri,
        // Prefer opening the actual app instead of a browser
        mode: LaunchMode.externalNonBrowserApplication,
      );
      return;
    }

    // 2) Fallback – open track in Spotify Web / browser
    final String webUrl = track['external_urls']['spotify'] as String;

    if (await canLaunchUrlString(webUrl)) {
      await launchUrlString(webUrl, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't open Spotify"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadTracks() async {
    final result = await SpotifyApiService.getPlaylistTracks(widget.playlistId);
    if (!mounted) return;

    setState(() {
      tracks = (result ?? []).where((t) => t['track'] != null).toList();
      isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    // If no songs marked, just go back
    if (_tracksToRemove.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final success = await SpotifyApiService.removeTracksFromPlaylist(
      widget.playlistId,
      _tracksToRemove,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${_tracksToRemove.length} song(s)'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove songs from playlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // SWIPE logic: left = remove, right = keep
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final track = tracks[previousIndex]['track'];
    final uri = track['uri'] as String;

    if (direction == CardSwiperDirection.left) {
      // LEFT → REMOVE
      if (!_tracksToRemove.contains(uri)) {
        _tracksToRemove.add(uri);
      }
      _currentAction = 'REMOVE';
      _removeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
    } else if (direction == CardSwiperDirection.right) {
      // RIGHT → KEEP
      _tracksToRemove.remove(uri);
      _currentAction = 'KEEP';
      _keepAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
    } else {
      _currentAction = '';
    }

    _swipeProgress = 1.0;

    // detect last card
    if (previousIndex == tracks.length - 1) {
      _finished = true;
    }

    _animationController.forward().then((_) => _animationController.reverse());

    setState(() {});
    return true;
  }

  void _swipeLeft() {
    _controller.swipe(CardSwiperDirection.left);
  }

  void _swipeRight() {
    _controller.swipe(CardSwiperDirection.right);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFinished() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Finished Swiping!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _tracksToRemove.isNotEmpty
                  ? 'You marked ${_tracksToRemove.length} song(s) to remove.'
                  : 'You kept the entire playlist!',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tracksToRemove.isNotEmpty
                      ? Colors.orange.shade700
                      : Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                ),
                onPressed: _tracksToRemove.isNotEmpty
                    ? _saveChanges
                    : () => Navigator.pop(context),
                child: Text(
                  _tracksToRemove.isNotEmpty
                      ? 'Save changes • Remove ${_tracksToRemove.length}'
                      : 'Back to playlist',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.playlistName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF214f4b),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : tracks.isEmpty
          ? const Center(
              child: Text(
                'No tracks to review',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : _finished
          ? _buildFinished()
          : Stack(
              children: [
                Column(
                  children: [
                    // Swipe area
                    Expanded(
                      child: CardSwiper(
                        controller: _controller,
                        cardsCount: tracks.length,
                        onSwipe: _onSwipe,
                        numberOfCardsDisplayed: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 25,
                        ),
                        allowedSwipeDirection: const AllowedSwipeDirection.only(
                          left: true,
                          right: true,
                        ),
                        cardBuilder: (context, index, percentX, percentY) {
                          final track = tracks[index]['track'];
                          final imageUrl = track['album']['images'].isNotEmpty
                              ? track['album']['images'][0]['url']
                              : null;

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // album art
                                  imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(color: Colors.grey[850]),
                                  // dark gradient
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.9),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 130,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => _openAndPlayTrack(track),
                                        child: Container(
                                          padding: const EdgeInsets.all(18),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black45,
                                                blurRadius: 16,
                                                offset: Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            size: 52,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // song info
                                  Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          track['name'],
                                          style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          track['artists']
                                              .map((a) => a['name'])
                                              .join(', '),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Bottom controls
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FloatingActionButton(
                                heroTag: 'remove',
                                backgroundColor: Colors.red.shade600,
                                onPressed: _swipeLeft,
                                child: const Icon(Icons.close, size: 38),
                              ),
                              FloatingActionButton(
                                heroTag: 'keep',
                                backgroundColor: Colors.green.shade600,
                                onPressed: _swipeRight,
                                child: const Icon(Icons.check, size: 38),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _tracksToRemove.isNotEmpty
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 6,
                              ),
                              onPressed: _saveChanges,
                              child: Text(
                                _tracksToRemove.isNotEmpty
                                    ? 'Save changes • Remove ${_tracksToRemove.length} song${_tracksToRemove.length > 1 ? 's' : ''}'
                                    : 'Save changes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // KEEP / REMOVE stamp
                if (_currentAction.isNotEmpty)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final isKeep = _currentAction == 'KEEP';
                      final opacity = _swipeProgress;
                      final color = isKeep ? Colors.green : Colors.red;
                      final animValue = isKeep
                          ? _keepAnimation.value
                          : _removeAnimation.value;

                      return Positioned(
                        top: 90,
                        left: isKeep ? null : 40,
                        right: isKeep ? 40 : null,
                        child: Transform.rotate(
                          angle: isKeep ? 0.3 : -0.3,
                          child: Opacity(
                            opacity: opacity * animValue,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 6,
                                ),
                              ),
                              child: Text(
                                _currentAction,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}
