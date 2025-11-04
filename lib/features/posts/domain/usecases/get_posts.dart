import '../entities/post_entity.dart';
import '../repositories/posts_repository.dart';

class GetPosts {
  final PostsRepository repository;

  GetPosts(this.repository);

  Stream<List<PostEntity>> call() {
    return repository.getPosts();
  }
}

