import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Requirement 3: Allow users to edit personal note and persist changes using Hive put()
  void _showEditNoteDialog(BuildContext context, Box box, dynamic key, Map favMap) {
    final noteController = TextEditingController(
      text: favMap['personalNote']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Note for Post #${favMap['id']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add or edit your personal study notes/remarks below:',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Personal Note',
                  hintText: 'Enter your note here...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedNote = noteController.text.trim();

                // Clone the map and update the personalNote
                final updatedMap = Map<String, dynamic>.from(favMap);
                updatedMap['personalNote'] = updatedNote;

                // Requirement 3: Persist changes using Hive put()
                await box.put(key, updatedMap);

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Note updated for Post #${favMap['id']}!',
                    ),
                    backgroundColor: Colors.blue.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save Note'),
            ),
          ],
        );
      },
    );
  }

  // Requirement 4: Delete favorite using Hive delete()
  void _confirmDelete(BuildContext context, Box box, dynamic key, Map favMap) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Remove from Favorites?'),
          content: Text(
            'Are you sure you want to remove Post #${favMap['id']} from your saved favorites?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.favoriteAccent,
              ),
              onPressed: () async {
                // Requirement 4: Add a delete icon to remove a favorite using Hive delete()
                await box.delete(key);
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Post #${favMap['id']} removed from Favorites.',
                    ),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Box favoritesBox = Hive.box('favoritesBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Use ValueListenableBuilder so UI automatically refreshes when box changes
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box box, _) {
          // Requirement 1: Read saved favorites from the Hive box using box.values
          final List<dynamic> rawValues = box.values.toList();

          // Requirement 5: Show an appropriate message when there are no saved favorites
          if (rawValues.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Saved Favorites Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Posts you mark as favorite will appear here and remain saved even after closing the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Browse Posts'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Requirement 2: Display saved posts using a ListView with titles, bodies, and personal notes
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: rawValues.length,
            itemBuilder: (context, index) {
              final item = rawValues[index];
              final favMap = item is Map ? Map<String, dynamic>.from(item) : {};
              final key = box.keyAt(index);

              final int postId = favMap['id'] ?? (key is int ? key : index + 1);
              final String title = favMap['title'] ?? 'No Title';
              final String body = favMap['body'] ?? '';
              final String personalNote = favMap['personalNote']?.toString() ?? '';

              return Dismissible(
                key: Key('fav_${key}_$postId'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.favoriteAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Remove',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onDismissed: (direction) async {
                  await box.delete(key);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Post #$postId removed from Favorites.'),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Post ID Badge + Delete Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Post #$postId',
                              style: const TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          // Requirement 4: Delete icon to remove a favorite using Hive delete()
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.favoriteAccent,
                            ),
                            tooltip: 'Remove from favorites',
                            onPressed: () => _confirmDelete(context, box, key, favMap),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Body
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Personal Note Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.sticky_note_2_outlined,
                              size: 18,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Personal Note:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    personalNote.isNotEmpty
                                        ? personalNote
                                        : 'No personal note added yet.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: personalNote.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      color: personalNote.isNotEmpty
                                          ? Colors.black87
                                          : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Requirement 3: Allow users to edit personal note
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(
                                personalNote.isNotEmpty ? 'Edit' : 'Add',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () => _showEditNoteDialog(
                                context,
                                box,
                                key,
                                favMap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            );
          },
          );
        },
      ),
    );
  }
}
