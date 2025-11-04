import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  User? getCurrentUser() => remoteDataSource.getCurrentUser();

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}

