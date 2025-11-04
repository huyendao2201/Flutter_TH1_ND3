# Các Bước Thực Hiện Dự Án

## Tổng quan
Dự án này xây dựng một ứng dụng mạng xã hội đơn giản với Flutter và Firebase, áp dụng Clean Architecture.

---

## Bước 1: Cấu hình Dependencies (pubspec.yaml)

### Mục tiêu
Thêm các package cần thiết cho dự án.

### Các package đã thêm:

#### Firebase
- `firebase_core` - Core SDK của Firebase
- `firebase_auth` - Xác thực người dùng
- `cloud_firestore` - Database NoSQL
- `firebase_storage` - Lưu trữ file

#### Utilities
- `image_picker` - Chọn ảnh từ thư viện/camera
- `dartz` - Functional programming (Either type)
- `equatable` - So sánh objects
- `intl` - Format ngày tháng

#### Testing
- `mockito` - Mock objects cho testing
- `build_runner` - Code generation

### Lệnh cài đặt:
```bash
flutter pub get
```

---

## Bước 2: Tạo Cấu Trúc Clean Architecture

### Cấu trúc thư mục:
```
lib/
├── core/
│   ├── constants/
│   │   └── firebase_constants.dart     # Hằng số Firebase
│   ├── di/
│   │   └── service_locator.dart        # Dependency Injection
│   ├── errors/
│   │   └── failures.dart               # Error handling
│   └── utils/
│       ├── typedef.dart                # Type definitions
│       └── image_picker_helper.dart    # Helper cho image picker
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in.dart
│   │   │       ├── sign_up.dart
│   │   │       └── sign_out.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │           └── auth_wrapper.dart
│   └── posts/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── posts_remote_data_source.dart
│       │   ├── models/
│       │   │   └── post_model.dart
│       │   └── repositories/
│       │       └── posts_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── post_entity.dart
│       │   ├── repositories/
│       │   │   └── posts_repository.dart
│       │   └── usecases/
│       │       ├── create_post.dart
│       │       └── get_posts.dart
│       └── presentation/
│           ├── pages/
│           │   ├── home_page.dart
│           │   └── create_post_page.dart
│           └── widgets/
│               └── post_card.dart
└── main.dart
```

### Giải thích các tầng:

#### 1. Domain Layer (Tầng nghiệp vụ)
- **Entities**: Các đối tượng nghiệp vụ thuần túy
- **Repositories**: Interface định nghĩa các phương thức
- **Use Cases**: Logic nghiệp vụ cụ thể

#### 2. Data Layer (Tầng dữ liệu)
- **Data Sources**: Giao tiếp với Firebase
- **Models**: Chuyển đổi giữa entities và Firebase
- **Repositories**: Implementation của repository interfaces

#### 3. Presentation Layer (Tầng giao diện)
- **Pages**: Các màn hình UI
- **Widgets**: Các component UI tái sử dụng

---

## Bước 3: Tạo Models và Entities

### UserEntity và UserModel

**Entity** (`user_entity.dart`):
```dart
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
}
```

**Model** (`user_model.dart`):
```dart
class UserModel extends UserEntity {
  // Chuyển đổi từ Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc)
  
  // Chuyển đổi sang Firestore
  Map<String, dynamic> toFirestore()
}
```

### PostEntity và PostModel

**Entity** (`post_entity.dart`):
```dart
class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final int likes;
}
```

**Model** (`post_model.dart`):
```dart
class PostModel extends PostEntity {
  factory PostModel.fromFirestore(DocumentSnapshot doc)
  Map<String, dynamic> toFirestore()
}
```

---

## Bước 4: Tạo Data Sources

### AuthRemoteDataSource
Xử lý authentication với Firebase:
- `signInWithEmailAndPassword()` - Đăng nhập
- `signUpWithEmailAndPassword()` - Đăng ký
- `signOut()` - Đăng xuất
- `authStateChanges` - Stream theo dõi trạng thái đăng nhập

### PostsRemoteDataSource
Xử lý posts với Firebase:
- `createPost()` - Tạo bài đăng (upload ảnh + lưu Firestore)
- `getPosts()` - Lấy danh sách bài đăng (Stream)

---

## Bước 5: Tạo Repositories

### Repository Pattern
Repositories cung cấp abstraction layer giữa data sources và use cases.

#### AuthRepository
```dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({...});
  Future<Either<Failure, UserEntity>> signUp({...});
  Future<Either<Failure, void>> signOut();
  Stream<User?> get authStateChanges;
}
```

#### PostsRepository
```dart
abstract class PostsRepository {
  Future<Either<Failure, void>> createPost({...});
  Stream<List<PostEntity>> getPosts();
}
```

### Either Type
Sử dụng `Either<Failure, Success>` từ package `dartz`:
- **Left**: Lỗi (Failure)
- **Right**: Thành công (Data)

---

## Bước 6: Tạo Use Cases

Use cases chứa business logic cụ thể.

### Auth Use Cases

#### SignIn
```dart
class SignIn {
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  });
}
```

#### SignUp
```dart
class SignUp {
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  });
}
```

#### SignOut
```dart
class SignOut {
  Future<Either<Failure, void>> call();
}
```

### Posts Use Cases

#### CreatePost
```dart
class CreatePost {
  Future<Either<Failure, void>> call({
    required String userId,
    required String userName,
    required File imageFile,
    required String description,
  });
}
```

#### GetPosts
```dart
class GetPosts {
  Stream<List<PostEntity>> call();
}
```

---

## Bước 7: Tạo UI Screens

### 1. AuthWrapper
Sử dụng `StreamBuilder` để theo dõi auth state:
```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData) return HomePage();
    return LoginPage();
  },
)
```

### 2. LoginPage
- Input: Email, Password
- Button: Đăng nhập
- Link: Chuyển đến RegisterPage

### 3. RegisterPage
- Input: Display Name, Email, Password, Confirm Password
- Validation: Kiểm tra mật khẩu khớp
- Button: Đăng ký

### 4. HomePage
- AppBar với nút logout
- GridView hiển thị posts
- StreamBuilder để cập nhật real-time
- FloatingActionButton: Tạo bài đăng mới

### 5. CreatePostPage
- Image picker: Chọn ảnh từ thư viện
- TextField: Nhập mô tả
- Button: Đăng bài

### 6. PostCard Widget
Hiển thị:
- Ảnh
- Tên người đăng
- Mô tả
- Số likes
- Ngày đăng

---

## Bước 8: Dependency Injection (Service Locator)

### ServiceLocator Pattern
Quản lý dependencies tập trung:

```dart
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  
  void init() {
    // Khởi tạo Firebase instances
    // Khởi tạo data sources
    // Khởi tạo repositories
    // Khởi tạo use cases
  }
  
  // Getters cho use cases
  SignIn get signIn => _signIn;
  SignUp get signUp => _signUp;
  CreatePost get createPost => _createPost;
  GetPosts get getPosts => _getPosts;
}
```

---

## Bước 9: Viết Tests

### Unit Tests

#### Test Entity
```dart
test('should create a PostEntity with all required fields', () {
  final post = PostEntity(...);
  expect(post.id, '1');
  // ...
});
```

#### Test Model
```dart
test('should convert to Firestore map correctly', () {
  final postModel = PostModel(...);
  final result = postModel.toFirestore();
  expect(result['userId'], 'user1');
  // ...
});
```

### Widget Tests

#### Test PostCard
```dart
testWidgets('should display post information correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PostCard(post: testPost),
      ),
    ),
  );
  
  expect(find.text('Test User'), findsOneWidget);
  // ...
});
```

### Chạy tests:
```bash
flutter test
flutter test --coverage
```

---

## Bước 10: Cấu hình Firebase

### Android

#### 1. Tạo Firebase project
- Truy cập Firebase Console
- Tạo project mới

#### 2. Thêm Android app
- Package name: `com.example.flutter_mxh`
- Tải `google-services.json`
- Copy vào `android/app/`

#### 3. Cập nhật Gradle files
`android/build.gradle.kts`:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

`android/app/build.gradle.kts`:
```kotlin
apply(plugin = "com.google.gms.google-services")
```

#### 4. Thêm permissions
`AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS

#### 1. Thêm iOS app
- Bundle ID từ Xcode project
- Tải `GoogleService-Info.plist`

#### 2. Copy file vào project
```bash
open ios/Runner.xcworkspace
```
Kéo thả `GoogleService-Info.plist` vào Xcode

#### 3. Thêm permissions
`Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần truy cập thư viện ảnh để chọn ảnh đăng bài</string>
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần truy cập camera để chụp ảnh</string>
```

### Firebase Services

#### 1. Authentication
- Enable Email/Password sign-in method

#### 2. Cloud Firestore
- Tạo database (chọn location gần nhất)
- Thiết lập Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                              request.auth.uid == resource.data.userId;
    }
  }
}
```

#### 3. Cloud Storage
- Tạo Storage bucket
- Thiết lập Security Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /posts/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.resource.size < 5 * 1024 * 1024;
    }
  }
}
```

---

## Bước 11: Chạy và Test Ứng Dụng

### 1. Cài đặt dependencies
```bash
flutter pub get
cd ios && pod install && cd ..
```

### 2. Chạy ứng dụng
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

### 3. Test các tính năng

#### Đăng ký:
1. Mở app
2. Click "Đăng ký"
3. Nhập thông tin
4. Kiểm tra Firebase Console → Authentication

#### Đăng nhập:
1. Nhập email/password
2. Kiểm tra chuyển sang HomePage

#### Tạo bài đăng:
1. Click FAB (Floating Action Button)
2. Chọn ảnh
3. Nhập mô tả
4. Click "Đăng"
5. Kiểm tra:
   - Firebase Console → Firestore (collection posts)
   - Firebase Console → Storage (folder posts/)

#### Xem bài đăng:
1. HomePage hiển thị GridView
2. Real-time updates khi có bài mới

---

## Tổng kết

### Đã hoàn thành:
✅ Clean Architecture với 3 tầng rõ ràng
✅ Firebase Authentication (Email/Password)
✅ Firebase Cloud Firestore (Database)
✅ Firebase Cloud Storage (File storage)
✅ Image Picker (Gallery)
✅ Real-time updates với StreamBuilder
✅ Unit Tests và Widget Tests
✅ Modern UI với Material Design 3
✅ Error handling với Either type
✅ Dependency Injection với Service Locator

### Có thể mở rộng:
- Like/Unlike posts
- Comments system
- User profiles
- Follow/Unfollow
- Notifications
- Stories feature
- Dark mode
- Internationalization

---

## Troubleshooting

### Lỗi build
```bash
flutter clean
flutter pub get
flutter run
```

### Lỗi Firebase
- Kiểm tra file cấu hình (google-services.json, GoogleService-Info.plist)
- Kiểm tra Firebase services đã enable
- Kiểm tra Security Rules

### Lỗi permissions
- Android: Kiểm tra AndroidManifest.xml
- iOS: Kiểm tra Info.plist

---

## Kết luận

Dự án này minh họa cách xây dựng một ứng dụng Flutter với:
1. **Clean Architecture** - Code dễ maintain và test
2. **Firebase** - Backend-as-a-Service
3. **Best Practices** - Error handling, dependency injection
4. **Testing** - Unit tests và Widget tests
5. **Modern UI** - Material Design 3

Dự án có thể dễ dàng mở rộng thêm các tính năng mới nhờ kiến trúc rõ ràng và tách biệt.

