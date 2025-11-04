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
}

