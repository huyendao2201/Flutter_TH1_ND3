import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';
import '../../data/datasources/posts_remote_data_source.dart';
import '../../data/repositories/posts_repository_impl.dart';
import '../pages/post_detail_screen.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Create repository instance directly
  late final _repository = PostsRepositoryImpl(
    remoteDataSource: PostsRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
    ),
  );
  bool _isLiked = false;
  bool _isLoading = true;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _likesCount = widget.post.likes;
  }

  Future<void> _checkIfLiked() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final isLiked = await _repository.isPostLikedByUser(
      postId: widget.post.id,
      userId: userId,
    );

    if (mounted) {
      setState(() {
        _isLiked = isLiked;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Optimistic update
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    final result = await _repository.toggleLike(
      postId: widget.post.id,
      userId: userId,
    );

    result.fold(
      (failure) {
        // Revert on failure
        if (mounted) {
          setState(() {
            _isLiked = !_isLiked;
            _likesCount += _isLiked ? 1 : -1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${failure.message}')),
          );
        }
      },
      (_) {
        // Success - state already updated optimistically
      },
    );
  }

  /// Check if imageUrl is Base64 or URL
  bool _isBase64(String str) {
    return !str.startsWith('http://') && !str.startsWith('https://');
  }

  /// Build image widget from Base64 or URL
  Widget _buildImage() {
    if (_isBase64(widget.post.imageUrl)) {
      // Decode Base64 to display image
      try {
        final Uint8List bytes = base64Decode(widget.post.imageUrl);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error, size: 48),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error, size: 48),
        );
      }
    } else {
      // Load from URL (backward compatibility if you had old posts)
      return Image.network(
        widget.post.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error, size: 48),
          );
        },
      );
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: widget.post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image (from Base64 or URL) - Tap to view detail
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToDetail(context),
              child: _buildImage(),
            ),
          ),

          // Post Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name and date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Description - Tap to view detail
                GestureDetector(
                  onTap: () => _navigateToDetail(context),
                  child: Text(
                    widget.post.description,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Likes and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like button
                    InkWell(
                      onTap: _isLoading ? null : _toggleLike,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: _isLiked ? Colors.red : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_likesCount',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isLiked ? Colors.red : Colors.grey[600],
                                fontWeight:
                                    _isLiked ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(widget.post.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

