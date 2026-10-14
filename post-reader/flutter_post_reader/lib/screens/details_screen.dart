import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Requirement 2 & 3:
    // Retrieve arguments using ModalRoute.of(context)!.settings.arguments as a Map
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int postId = args['id'] as int;
    final String title = args['title'] as String;
    final String body = args['body'] as String;

    // Access the opened Hive favorites box
    final Box favoritesBox = Hive.box('favoritesBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        // Requirement 8: Include a back button using Navigator.pop(context)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box box, _) {
          // Check if this post ID already exists in the box
          final bool isAlreadyFavorite = box.containsKey(postId);
          final existingFav = box.get(postId);
          final String personalNote =
              existingFav != null && existingFav is Map && existingFav['personalNote'] != null
                  ? existingFav['personalNote'].toString()
                  : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Requirement 4: Display the full post details in a readable card layout
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post ID Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Post #$postId',
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Full Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 14),
                        // Label
                        const Text(
                          'Content',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Full Body
                        Text(
                          body,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Favorite Status & Action Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (isAlreadyFavorite) ...[
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: AppTheme.favoriteAccent),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'This post is saved in your Favorites.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.favoriteAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (personalNote.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Note: $personalNote',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],

                        // Requirement 5, 6, 7:
                        // Save to Favorites button; save post as Map in Hive with ID as key; show messages
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAlreadyFavorite
                                ? AppTheme.favoriteAccent
                                : AppTheme.primaryBlue,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          icon: Icon(
                            isAlreadyFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: Text(
                            isAlreadyFavorite
                                ? 'Already in Favorites'
                                : 'Save to Favorites',
                          ),
                          onPressed: () {
                            if (box.containsKey(postId)) {
                              // Requirement 7: Show message if already in Favorites
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Post #$postId is already in your Favorites!',
                                  ),
                                  backgroundColor: Colors.orange.shade800,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              // Requirement 6: Save the post as a Map in Hive, using post ID as key
                              box.put(postId, {
                                'id': postId,
                                'title': title,
                                'body': body,
                                'personalNote': '',
                                'savedAt': DateTime.now().toIso8601String(),
                              });

                              // Requirement 7: Show a message when a post is saved
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Post #$postId successfully saved to Favorites!',
                                  ),
                                  backgroundColor: Colors.green.shade700,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
