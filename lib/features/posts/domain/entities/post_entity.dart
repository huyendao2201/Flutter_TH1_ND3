import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final int likes;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    this.likes = 0,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        imageUrl,
        description,
        createdAt,
        likes,
      ];
}

