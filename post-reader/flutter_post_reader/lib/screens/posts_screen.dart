import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../utils/english_content.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  // Base URL for the JSONPlaceholder API
  static const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Requirement 1: Fetch posts inside an asynchronous method called from initState()
    _fetchPosts();
  }

  // Requirement 1, 2, 3, 5, 6:
  // Fetch posts from API, check status code 200, parse with jsonDecode, handle loading and errors
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      // Requirement 2: Check whether status code is 200
      if (response.statusCode == 200) {
        // Requirement 3: Parse response using jsonDecode()
        final List<dynamic> data = jsonDecode(response.body);
        final englishPosts = data.map((item) {
          if (item is Map) {
            return EnglishContent.toEnglish(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
        setState(() {
          _posts = englishPosts;
          _isLoading = false;
        });
      } else {
        // Requirement 6: Display error message on screen
        setState(() {
          _errorMessage =
              'Failed to load posts. Server returned status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Requirement 6: Handle exceptions and show error message on screen
      setState(() {
        _errorMessage = 'Network connection error: $e';
        _isLoading = false;
      });
    }
  }

  // Requirement 8, 9, 10:
  // Show dialog with title & body fields, both required, submit with http.post()
  void _showCreatePostDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    'Create New Post',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Fill in both fields to submit a new post to the JSONPlaceholder API.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      // Title field (required)
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Post Title *',
                          hintText: 'Enter title here',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Body field (required)
                      TextFormField(
                        controller: bodyController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Post Body *',
                          hintText: 'Enter body text here',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 50),
                            child: Icon(Icons.description),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Body is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isSubmitting = true;
                            });

                            await _submitNewPost(
                              title: titleController.text.trim(),
                              body: bodyController.text.trim(),
                              dialogContext: dialogContext,
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Requirement 9 & 10:
  // Submit new post with http.post(), headers, jsonEncode, check status code 201
  Future<void> _submitNewPost({
    required String title,
    required String body,
    required BuildContext dialogContext,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );

      // Close the dialog first
      Navigator.of(dialogContext).pop();

      // Requirement 10: Check status code 201 for success
      if (response.statusCode == 201) {
        final newPost = jsonDecode(response.body);

        setState(() {
          // Add created post to top of the list for immediate feedback
          _posts.insert(0, newPost);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Post created successfully! (Status 201, ID: ${newPost['id']})',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to create post. Server returned status: ${response.statusCode}',
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.of(dialogContext).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting post: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post Reader & Favorites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'JSONPlaceholder Feed',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Refresh action
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh feed',
            onPressed: _fetchPosts,
          ),
          // Requirement 7: AppBar button that navigates to Favorites using Navigator.pushNamed(context, 'favorites')
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.pushNamed(context, 'favorites');
            },
          ),
        ],
      ),
      // Requirement 8: FloatingActionButton to open dialog with title & body
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create New Post',
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add, size: 28),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Requirement 5: Show loading indicator while fetching data
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryBlue),
            SizedBox(height: 16),
            Text(
              'Fetching posts from JSONPlaceholder...',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Requirement 6: Display error message on screen if request fails
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Requirement 4: Display posts using ListView.builder and cards showing title and preview of body
    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final int postId = post['id'] is int
              ? post['id']
              : int.tryParse(post['id'].toString()) ?? index + 1;
          final String title = post['title'] ?? 'No Title';
          final String body = post['body'] ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$postId',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black38,
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  'details',
                  arguments: {
                    'id': postId,
                    'title': title,
                    'body': body,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
