// test/widget/login_page_three_tests.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swipify/pages/login_page.dart';
import 'package:swipify/providers/spotify_auth_provider.dart';

void main() {
  testWidgets('1. LoginPage displays the Swipify logo', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SpotifyAuthProvider(),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.image(const AssetImage('assets/images/swipify.jpg')), findsOneWidget);
  });

  testWidgets('2. LoginPage displays "Login With Spotify" text', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SpotifyAuthProvider(),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('Login With Spotify'), findsOneWidget);
  });

  testWidgets('3. LoginPage has an ElevatedButton', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SpotifyAuthProvider(),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}