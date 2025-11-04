import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mxh/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_mxh/features/posts/presentation/widgets/post_card.dart';

void main() {
  group('PostCard Widget', () {
    late PostEntity testPost;

    setUp(() {
      testPost = PostEntity(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://via.placeholder.com/300',
        description: 'This is a test post description',
        createdAt: DateTime(2023, 1, 1),
        likes: 10,
      );
    });

    testWidgets('should display post information correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('This is a test post description'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('01/01/2023'), findsOneWidget);
    });

    testWidgets('should display like icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should display image with correct URL', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: testPost),
          ),
        ),
      );

      // Assert
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image image = tester.widget(imageFinder);
      final NetworkImage networkImage = image.image as NetworkImage;
      expect(networkImage.url, testPost.imageUrl);
    });

    testWidgets('should truncate long description', (tester) async {
      // Arrange
      final longDescriptionPost = PostEntity(
        id: '1',
        userId: 'user1',
        userName: 'Test User',
        imageUrl: 'https://via.placeholder.com/300',
        description: 'This is a very long description that should be truncated '
            'when displayed in the post card widget because it exceeds the maximum '
            'number of lines allowed for the description text',
        createdAt: DateTime(2023, 1, 1),
        likes: 10,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: longDescriptionPost),
          ),
        ),
      );

      // Assert
      final textFinder = find.text(longDescriptionPost.description);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}

