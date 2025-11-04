import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../posts/presentation/pages/home_page.dart';
import '../pages/login_page.dart';
import '../../domain/usecases/sign_in.dart';

class AuthWrapper extends StatelessWidget {
  final SignIn signIn;

  const AuthWrapper({super.key, required this.signIn});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show home page if user is logged in
        if (snapshot.hasData) {
          return const HomePage();
        }

        // Show login page if user is not logged in
        return LoginPage(signIn: signIn);
      },
    );
  }
}

