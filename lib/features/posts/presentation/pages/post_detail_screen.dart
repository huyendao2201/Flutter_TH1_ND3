import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';
import '../../data/datasources/posts_remote_data_source.dart';
import '../../data/repositories/posts_repository_impl.dart';

class PostDetailScreen extends StatefulWidget {
  final PostEntity post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
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
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thích bài viết')),
        );
      }
      return;
    }

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
          fit: BoxFit.contain,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              color: Colors.grey[300],
              child: const Icon(Icons.error, size: 48),
            );
          },
        );
      } catch (e) {
        return Container(
          height: 300,
          color: Colors.grey[300],
          child: const Icon(Icons.error, size: 48),
        );
      }
    } else {
      // Load from URL (backward compatibility if you had old posts)
      return Image.network(
        widget.post.imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 300,
            alignment: Alignment.center,
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
            height: 300,
            color: Colors.grey[300],
            child: const Icon(Icons.error, size: 48),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            _buildImage(),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info and date
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          widget.post.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(widget.post.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.post.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // Like button
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: _isLoading ? null : _toggleLike,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _isLiked
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 28,
                                  color: _isLiked ? Colors.red : Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$_likesCount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _isLiked ? Colors.red : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

