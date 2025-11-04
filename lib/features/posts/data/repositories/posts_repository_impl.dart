import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;

  PostsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createPost({
    required String userId,
    required String userName,
    required File imageFile,
    required String description,
  }) async {
    try {
      await remoteDataSource.createPost(
        userId: userId,
        userName: userName,
        imageFile: imageFile,
        description: description,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<PostEntity>> getPosts() {
    return remoteDataSource.getPosts();
  }

  @override
  Future<Either<Failure, void>> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.toggleLike(
        postId: postId,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isPostLikedByUser({
    required String postId,
    required String userId,
  }) async {
    return await remoteDataSource.isPostLikedByUser(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Stream<int> getLikesCount(String postId) {
    return remoteDataSource.getLikesCount(postId);
  }
}

