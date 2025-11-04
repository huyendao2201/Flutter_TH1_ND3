import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mxh/features/posts/data/models/post_model.dart';
import 'package:flutter_mxh/features/posts/domain/entities/post_entity.dart';

void main() {
  group('PostModel', () {
    test('should be a subclass of PostEntity', () {
      // Arrange
      final postModel = PostModel(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: DateTime.now(),
        likes: 5,
      );

      // Assert
      expect(postModel, isA<PostEntity>());
    });

    test('should convert to Firestore map correctly', () {
      // Arrange
      final createdAt = DateTime(2023, 1, 1, 12, 0, 0);
      final postModel = PostModel(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: createdAt,
        likes: 5,
      );

      // Act
      final result = postModel.toFirestore();

      // Assert
      expect(result['userId'], 'user1');
      expect(result['userName'], 'Test User');
      expect(result['imageUrl'], 'https://example.com/image.jpg');
      expect(result['description'], 'Test description');
      expect(result['createdAt'], isA<Timestamp>());
      expect(result['likes'], 5);
    });

    test('should create PostModel from PostEntity', () {
      // Arrange
      final entity = PostEntity(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: DateTime.now(),
        likes: 5,
      );

      // Act
      final model = PostModel.fromEntity(entity);

      // Assert
      expect(model.id, entity.id);
      expect(model.userId, entity.userId);
      expect(model.userName, entity.userName);
      expect(model.imageUrl, entity.imageUrl);
      expect(model.description, entity.description);
      expect(model.createdAt, entity.createdAt);
      expect(model.likes, entity.likes);
    });
  });
}

