import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final String username;

  const UserProfileCard({
    super.key,
    required this.profile,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        profile != null && profile!['images'] != null && profile!['images'].isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      profile!['images'][0]['url'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.green,
                  ),
            const SizedBox(height: 12),
            Text(
              'Welcome Back !',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              username,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
