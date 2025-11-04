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
}

