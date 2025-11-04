import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';

// Posts
import '../../features/posts/data/datasources/posts_remote_data_source.dart';
import '../../features/posts/data/repositories/posts_repository_impl.dart';
import '../../features/posts/domain/repositories/posts_repository.dart';
import '../../features/posts/domain/usecases/create_post.dart';
import '../../features/posts/domain/usecases/get_posts.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Firebase instances
  late final FirebaseAuth _firebaseAuth;
  late final FirebaseFirestore _firestore;

  // Auth
  late final AuthRemoteDataSource _authRemoteDataSource;
  late final AuthRepository _authRepository;
  late final SignIn _signIn;
  late final SignUp _signUp;
  late final SignOut _signOut;

  // Posts
  late final PostsRemoteDataSource _postsRemoteDataSource;
  late final PostsRepository _postsRepository;
  late final CreatePost _createPost;
  late final GetPosts _getPosts;

  void init() {
    // Firebase instances
    _firebaseAuth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;

    // Auth
    _authRemoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: _firebaseAuth,
      firestore: _firestore,
    );
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
    );
    _signIn = SignIn(_authRepository);
    _signUp = SignUp(_authRepository);
    _signOut = SignOut(_authRepository);

    // Posts (không cần FirebaseStorage nữa - dùng Base64!)
    _postsRemoteDataSource = PostsRemoteDataSourceImpl(
      firestore: _firestore,
    );
    _postsRepository = PostsRepositoryImpl(
      remoteDataSource: _postsRemoteDataSource,
    );
    _createPost = CreatePost(_postsRepository);
    _getPosts = GetPosts(_postsRepository);
  }

  // Getters
  SignIn get signIn => _signIn;
  SignUp get signUp => _signUp;
  SignOut get signOut => _signOut;
  CreatePost get createPost => _createPost;
  GetPosts get getPosts => _getPosts;
}

