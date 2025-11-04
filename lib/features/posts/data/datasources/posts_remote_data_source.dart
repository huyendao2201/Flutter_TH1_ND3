import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/post_entity.dart';
import '../models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<void> createPost({
    required String userId,
    required String userName,
    required File imageFile,
    required String description,
  });

  Stream<List<PostEntity>> getPosts();
  
  Future<void> toggleLike({
    required String postId,
    required String userId,
  });
  
  Future<bool> isPostLikedByUser({
    required String postId,
    required String userId,
  });
  
  Stream<int> getLikesCount(String postId);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final FirebaseFirestore _firestore;

  PostsRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  /// Convert image to Base64 (no Cloud Storage needed!)
  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Check size - Firestore document max size is 1MB
      // Base64 is about 33% larger than original
      if (base64String.length > 800000) { // ~800KB to be safe
        throw Exception('Ảnh quá lớn! Vui lòng chọn ảnh nhỏ hơn 500KB');
      }
      
      return base64String;
    } catch (e) {
      throw Exception('Lỗi khi xử lý ảnh: $e');
    }
  }

  @override
  Future<void> createPost({
    required String userId,
    required String userName,
    required File imageFile,
    required String description,
  }) async {
    try {
      // Convert image to Base64 (no Cloud Storage needed!)
      final imageBase64 = await _convertImageToBase64(imageFile);

      // Create post document
      final postModel = PostModel(
        id: '',
        userId: userId,
        userName: userName,
        imageUrl: imageBase64, // Store Base64 string instead of URL
        description: description,
        createdAt: DateTime.now(),
        likes: 0,
      );

      await _firestore
          .collection(FirebaseConstants.postsCollection)
          .add(postModel.toFirestore());
    } catch (e) {
      throw Exception('Không tạo được bài đăng: ${e.toString()}');
    }
  }

  @override
  Stream<List<PostEntity>> getPosts() {
    try {
      return _firestore
          .collection(FirebaseConstants.postsCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Không nhận được bài viết: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final likeDocRef = _firestore
          .collection(FirebaseConstants.postsCollection)
          .doc(postId)
          .collection('likes')
          .doc(userId);

      final likeDoc = await likeDocRef.get();
      final postRef = _firestore
          .collection(FirebaseConstants.postsCollection)
          .doc(postId);

      // Get current post data to ensure likes field exists and is valid
      final postDoc = await postRef.get();
      final postData = postDoc.data();
      
      // Initialize or fix likes field if it doesn't exist or is negative
      if (postData != null) {
        final currentLikes = postData['likes'] as int?;
        if (currentLikes == null || currentLikes < 0) {
          await postRef.update({'likes': 0});
        }
      }

      if (likeDoc.exists) {
        // Unlike: remove like document and decrease likes count
        await likeDocRef.delete();
        // Get updated data after initialization
        final updatedDoc = await postRef.get();
        final updatedData = updatedDoc.data();
        final currentLikes = (updatedData?['likes'] as int?) ?? 0;
        
        // Only decrement if likes > 0
        if (currentLikes > 0) {
          await postRef.update({
            'likes': FieldValue.increment(-1),
          });
        }
      } else {
        // Like: add like document and increase likes count
        await likeDocRef.set({
          'userId': userId,
          'likedAt': FieldValue.serverTimestamp(),
        });
        await postRef.update({
          'likes': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception('Không thể like/unlike bài viết: ${e.toString()}');
    }
  }

  @override
  Future<bool> isPostLikedByUser({
    required String postId,
    required String userId,
  }) async {
    try {
      final likeDoc = await _firestore
          .collection(FirebaseConstants.postsCollection)
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();

      return likeDoc.exists;
    } catch (e) {
      // Log error but don't crash - just return false
      print('Error checking if post is liked: $e');
      return false;
    }
  }

  @override
  Stream<int> getLikesCount(String postId) {
    try {
      return _firestore
          .collection(FirebaseConstants.postsCollection)
          .doc(postId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return 0;
        final data = doc.data();
        return data?['likes'] ?? 0;
      });
    } catch (e) {
      return Stream.value(0);
    }
  }
}

