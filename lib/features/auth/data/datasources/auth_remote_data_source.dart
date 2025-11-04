import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();

  Stream<User?> get authStateChanges;

  User? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User not found');
      }

      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
}

