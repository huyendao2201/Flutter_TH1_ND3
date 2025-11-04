import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/posts_repository.dart';

class CreatePost {
  final PostsRepository repository;

  CreatePost(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required String userName,
    required File imageFile,
    required String description,
  }) async {
    return await repository.createPost(
      userId: userId,
      userName: userName,
      imageFile: imageFile,
      description: description,
    );
  }
}

