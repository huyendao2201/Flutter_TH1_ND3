import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mxh/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('should create a UserEntity with all required fields', () {
      // Arrange & Act
      const user = UserEntity(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      // Assert
      expect(user.uid, '123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
    });

    test('should compare two UserEntity objects correctly', () {
      // Arrange
      const user1 = UserEntity(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      const user2 = UserEntity(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      // Assert
      expect(user1, equals(user2));
    });

    test('should not be equal if any field is different', () {
      // Arrange
      const user1 = UserEntity(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      const user2 = UserEntity(
        uid: '456', // Different uid
        email: 'test@example.com',
        displayName: 'Test User',
      );

      // Assert
      expect(user1, isNot(equals(user2)));
    });
  });
}

