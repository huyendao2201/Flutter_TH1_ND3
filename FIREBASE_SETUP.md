# Hướng dẫn cấu hình Firebase

> **⚠️ LƯU Ý QUAN TRỌNG**: Dự án này **KHÔNG CẦN** Cloud Storage nữa!
> 
> Ảnh được lưu dưới dạng **Base64 trong Firestore** để tránh phải nâng cấp lên Blaze plan.
> Bạn chỉ cần cấu hình **Authentication** và **Cloud Firestore** là đủ.
>
> Xem file `ALTERNATIVE_STORAGE_SOLUTIONS.md` để hiểu thêm về giải pháp này.

---

## 1. Tạo project Firebase

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" hoặc "Thêm dự án"
3. Đặt tên project (ví dụ: flutter-mxh)
4. Tắt Google Analytics nếu không cần (có thể bật sau)
5. Click "Create project"

## 2. Cấu hình Firebase cho Android

### Bước 1: Thêm Android app vào Firebase project

1. Trong Firebase Console, click icon Android
2. Điền thông tin:
   - **Android package name**: Lấy từ file `android/app/build.gradle.kts` (namespace)
   - **App nickname**: Tùy chọn (ví dụ: Flutter MXH Android)
   - **Debug signing certificate SHA-1**: Tùy chọn (cần cho Google Sign-In)

### Bước 2: Tải file google-services.json

1. Tải file `google-services.json`
2. Copy file này vào thư mục `android/app/`

### Bước 3: Cập nhật build.gradle files

File `android/build.gradle.kts` (đã được cấu hình sẵn):
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

File `android/app/build.gradle.kts` (thêm vào cuối file):
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}
```

## 3. Cấu hình Firebase cho iOS

### Bước 1: Thêm iOS app vào Firebase project

1. Trong Firebase Console, click icon iOS
2. Điền thông tin:
   - **iOS bundle ID**: Lấy từ file `ios/Runner.xcodeproj/project.pbxproj` hoặc Xcode
   - **App nickname**: Tùy chọn (ví dụ: Flutter MXH iOS)
   - **App Store ID**: Tùy chọn

### Bước 2: Tải file GoogleService-Info.plist

1. Tải file `GoogleService-Info.plist`
2. Mở project iOS trong Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Kéo thả file `GoogleService-Info.plist` vào Xcode project (vào thư mục Runner)
4. Đảm bảo chọn "Copy items if needed" và target là "Runner"

### Bước 3: Cập nhật Podfile (nếu cần)

File `ios/Podfile` đã được Flutter tự động cấu hình.

## 4. Cấu hình Firebase Services

### Authentication

1. Trong Firebase Console, vào **Authentication**
2. Click "Get started"
3. Vào tab "Sign-in method"
4. Enable "Email/Password"

### Cloud Firestore

1. Trong Firebase Console, vào **Firestore Database**
2. Click "Create database"
3. Chọn mode:
   - **Test mode** (cho development): Cho phép read/write tự do
   - **Production mode**: Yêu cầu rules bảo mật
4. Chọn location (ví dụ: asia-southeast1 cho Vietnam)

#### Security Rules mẫu cho Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                              request.auth.uid == resource.data.userId;
    }
  }
}
```

### Cloud Storage

1. Trong Firebase Console, vào **Storage**
2. Click "Get started"
3. Chọn rules mode (Test mode cho development)
4. Chọn location (giống với Firestore)

#### Security Rules mẫu cho Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /posts/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                     request.resource.contentType.matches('image/.*');
    }
  }
}
```

## 5. Cấu hình permissions

### Android

File `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Thêm permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <application ...>
        ...
    </application>
</manifest>
```

### iOS

File `ios/Runner/Info.plist`:
```xml
<dict>
    <!-- Thêm descriptions -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Ứng dụng cần truy cập thư viện ảnh để chọn ảnh đăng bài</string>
    
    <key>NSCameraUsageDescription</key>
    <string>Ứng dụng cần truy cập camera để chụp ảnh</string>
    
    <key>NSMicrophoneUsageDescription</key>
    <string>Ứng dụng cần truy cập microphone để quay video</string>
    
    <!-- Existing keys -->
    ...
</dict>
```

## 6. Chạy ứng dụng

### Cài đặt dependencies

```bash
flutter pub get
cd ios && pod install && cd ..
```

### Chạy trên Android

```bash
flutter run
```

### Chạy trên iOS

```bash
flutter run
```

## 7. Kiểm tra

1. Mở app
2. Đăng ký tài khoản mới
3. Kiểm tra Firebase Console:
   - **Authentication**: Xem user mới được tạo
   - **Firestore**: Xem collection `users` có document mới
4. Tạo bài đăng mới:
   - Chọn ảnh từ thư viện
   - Nhập mô tả
   - Click "Đăng"
5. Kiểm tra Firebase Console:
   - **Firestore**: Xem collection `posts` có document mới
   - **Storage**: Xem ảnh được upload trong folder `posts/`

## Lưu ý

- File `google-services.json` (Android) và `GoogleService-Info.plist` (iOS) **không được** commit lên Git
- Đã thêm vào `.gitignore`:
  ```
  # Firebase
  android/app/google-services.json
  ios/Runner/GoogleService-Info.plist
  ```

## Troubleshooting

### Lỗi "No Firebase App '[DEFAULT]' has been created"
- Đảm bảo đã gọi `await Firebase.initializeApp()` trong `main()`

### Lỗi build Android
- Kiểm tra file `google-services.json` đã được copy đúng vị trí
- Chạy `flutter clean` và build lại

### Lỗi build iOS
- Mở Xcode và kiểm tra file `GoogleService-Info.plist` đã được thêm vào project
- Chạy `pod install` trong thư mục `ios/`
- Clean build folder trong Xcode (Command + Shift + K)

