import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mxh/features/posts/domain/entities/post_entity.dart';

void main() {
  group('PostEntity', () {
    test('should create a PostEntity with all required fields', () {
      // Arrange
      final createdAt = DateTime.now();

      // Act
      final post = PostEntity(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: createdAt,
        likes: 5,
      );

      // Assert
      expect(post.id, '1');
      expect(post.userId, 'user1');
      expect(post.userName, 'Test User');
      expect(post.imageUrl, 'https://example.com/image.jpg');
      expect(post.description, 'Test description');
      expect(post.createdAt, createdAt);
      expect(post.likes, 5);
    });

    test('should have default likes value of 0', () {
      // Arrange & Act
      final post = PostEntity(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: DateTime.now(),
      );

      // Assert
      expect(post.likes, 0);
    });

    test('should compare two PostEntity objects correctly', () {
      // Arrange
      final createdAt = DateTime.now();
      final post1 = PostEntity(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: createdAt,
        likes: 5,
      );
      final post2 = PostEntity(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: createdAt,
        likes: 5,
      );

      // Assert
      expect(post1, equals(post2));
    });

    test('should not be equal if any field is different', () {
      // Arrange
      final createdAt = DateTime.now();
      final post1 = PostEntity(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: createdAt,
        likes: 5,
      );
      final post2 = PostEntity(
        id: '2', // Different id
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Test description',
        createdAt: createdAt,
        likes: 5,
      );

      // Assert
      expect(post1, isNot(equals(post2)));
    });
  });
}

