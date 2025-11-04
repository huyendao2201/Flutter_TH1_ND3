# Flutter Social Media App

Ứng dụng mạng xã hội đơn giản được xây dựng bằng Flutter và Firebase.

## Tính năng

- ✅ Đăng ký và đăng nhập bằng email/password (Firebase Authentication)
- ✅ Tải ảnh lên từ thư viện hoặc camera
- ✅ Lưu trữ ảnh trên Firebase Cloud Storage
- ✅ Hiển thị danh sách bài đăng theo thời gian thực (Cloud Firestore)
- ✅ Giao diện hiện đại với Material Design 3
- ✅ Kiến trúc Clean Architecture
- ✅ Unit Tests và Widget Tests

## Kiến trúc

Dự án sử dụng **Clean Architecture** với 3 tầng:

```
lib/
├── core/                       # Core utilities
│   ├── constants/             # Hằng số
│   ├── di/                    # Dependency Injection
│   ├── errors/                # Error handling
│   └── utils/                 # Utilities
│
├── features/                  # Features
│   ├── auth/                  # Authentication feature
│   │   ├── data/             
│   │   │   ├── datasources/  # Firebase Auth data source
│   │   │   ├── models/       # User model
│   │   │   └── repositories/ # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/     # User entity
│   │   │   ├── repositories/ # Repository interface
│   │   │   └── usecases/     # SignIn, SignUp, SignOut
│   │   └── presentation/
│   │       ├── pages/        # Login, Register pages
│   │       └── widgets/      # Auth wrapper
│   │
│   └── posts/                 # Posts feature
│       ├── data/
│       │   ├── datasources/  # Firestore & Storage data source
│       │   ├── models/       # Post model
│       │   └── repositories/ # Repository implementation
│       ├── domain/
│       │   ├── entities/     # Post entity
│       │   ├── repositories/ # Repository interface
│       │   └── usecases/     # CreatePost, GetPosts
│       └── presentation/
│           ├── pages/        # Home, CreatePost pages
│           └── widgets/      # PostCard widget
│
└── main.dart                  # Entry point
```

## Công nghệ sử dụng

### Flutter Packages

- `firebase_core` - Firebase SDK core
- `firebase_auth` - Authentication
- `cloud_firestore` - NoSQL database
- `firebase_storage` - File storage
- `image_picker` - Chọn ảnh từ thư viện/camera
- `dartz` - Functional programming (Either type)
- `equatable` - Value comparison
- `intl` - Internationalization

### Testing

- `flutter_test` - Testing framework
- `mockito` - Mocking
- `build_runner` - Code generation

## Yêu cầu hệ thống

- Flutter SDK: >= 3.8.1
- Dart SDK: >= 3.8.1
- Android: minSdkVersion 21
- iOS: iOS 12.0+

## Cài đặt

### 1. Clone repository

```bash
git clone <repository-url>
cd flutter_mxh
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Cấu hình Firebase

Làm theo hướng dẫn chi tiết trong file [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

Tóm tắt:
1. Tạo Firebase project
2. Thêm Android app và tải `google-services.json`
3. Thêm iOS app và tải `GoogleService-Info.plist`
4. Enable Authentication (Email/Password)
5. Tạo Cloud Firestore database
6. Tạo Cloud Storage bucket

### 4. Chạy ứng dụng

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (chưa hỗ trợ đầy đủ)
flutter run -d chrome
```

## Chạy Tests

```bash
# Tất cả tests
flutter test

# Test cụ thể
flutter test test/features/posts/domain/entities/post_entity_test.dart

# Test với coverage
flutter test --coverage
```

## Cấu trúc Database

### Firestore Collections

#### users
```json
{
  "userId": {
    "email": "user@example.com",
    "displayName": "User Name"
  }
}
```

#### posts
```json
{
  "postId": {
    "userId": "userId",
    "userName": "User Name",
    "imageUrl": "https://...",
    "description": "Post description",
    "createdAt": Timestamp,
    "likes": 0
  }
}
```

### Storage Structure

```
posts/
  └── <timestamp>.jpg
```

## Tính năng nâng cao (Có thể mở rộng)

- [ ] Like/Unlike posts
- [ ] Comments
- [ ] User profiles
- [ ] Follow/Unfollow users
- [ ] Real-time notifications
- [ ] Stories
- [ ] Dark mode
- [ ] Multi-language support

## Troubleshooting

### Lỗi build Android

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Lỗi build iOS

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Lỗi Firebase

Kiểm tra:
- File `google-services.json` (Android)
- File `GoogleService-Info.plist` (iOS)
- Firebase services đã được enable
- Internet permission đã được thêm

## License

MIT License

## Liên hệ

- Email: your-email@example.com
- GitHub: your-github-username
