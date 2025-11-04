import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.imageUrl,
    required super.description,
    required super.createdAt,
    super.likes,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      imageUrl: entity.imageUrl,
      description: entity.description,
      createdAt: entity.createdAt,
      likes: entity.likes,
    );
  }
}

