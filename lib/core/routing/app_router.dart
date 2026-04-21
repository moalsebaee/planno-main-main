import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../splash_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/task_home_screen.dart';
import '../../screens/profile_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const SignInPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(path: '/home', builder: (context, state) => const TaskHomeScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  redirect: (context, state) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final isAuth = authViewModel.currentUser != null;

    final location = state.matchedLocation;
    if (!isAuth &&
        !location.startsWith('/login') &&
        !location.startsWith('/signup') &&
        !location.startsWith('/splash')) {
      return '/login';
    }
    if (isAuth &&
        (location.startsWith('/login') || location.startsWith('/signup'))) {
      return '/home';
    }
    return null;
  },
);
