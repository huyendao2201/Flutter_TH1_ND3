import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Service Locator
  final serviceLocator = ServiceLocator();
  serviceLocator.init();
  
  runApp(MyApp(serviceLocator: serviceLocator));
}

class MyApp extends StatelessWidget {
  final ServiceLocator serviceLocator;

  const MyApp({super.key, required this.serviceLocator});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: AuthWrapper(signIn: serviceLocator.signIn),
    );
  }
}
