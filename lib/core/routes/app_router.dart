import 'package:go_router/go_router.dart';
import 'package:todo/Screens/home_screen.dart';
import 'package:todo/Screens/login_screen.dart';
import 'package:todo/Screens/splash_screen.dart';
import 'package:todo/models/Task_model.dart';

import '../../Screens/Signup_screen.dart';
import '../../Screens/add_task_screen.dart';
import '../../Screens/all_tasks_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/tasks/:section',
        builder: (context, state) {
          final section = state.pathParameters['section'] ?? 'all';
          return AllTasksScreen(
            section: section,
          );
        },
      ),

      GoRoute(
        path: '/add-task',
        builder: (context, state) {
          final task = state.extra as TaskModel?;
          return AddTaskScreen(initialTask: task);
        },
      ),
    ],
  );
}
