import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/post_entity.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  /// Check if imageUrl is Base64 or URL
  bool _isBase64(String str) {
    return !str.startsWith('http://') && !str.startsWith('https://');
  }

  /// Build image widget from Base64 or URL
  Widget _buildImage() {
    if (_isBase64(post.imageUrl)) {
      // Decode Base64 to display image
      try {
        final Uint8List bytes = base64Decode(post.imageUrl);
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
        post.imageUrl,
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
          // Image (from Base64 or URL)
          Expanded(
            child: _buildImage(),
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
                        post.userName,
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

                // Description
                Text(
                  post.description,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Likes and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likes}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(post.createdAt),
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

