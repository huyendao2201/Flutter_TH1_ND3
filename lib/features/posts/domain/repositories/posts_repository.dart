import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';

abstract class PostsRepository {
  Future<Either<Failure, void>> createPost({
    required String userId,
    required String userName,
    required File imageFile,
    required String description,
  });

  Stream<List<PostEntity>> getPosts();
}

