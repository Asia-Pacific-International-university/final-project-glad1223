import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'core/navigation/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/user_repositories.dart'; // Assuming this path
import 'data/repositories/user_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'data/repositories/leaderboard_repository_impl.dart';
import 'package:final_project/domain/repositories/leaderboard_repositories.dart'; // Assuming this path
import 'presentation/providers/leaderboard_provider.dart';
import 'data/datasources/remote/api_client.dart'; // Assuming you'll create this

final getIt = GetIt.instance;

void setupDependencies() {
  // Register your ApiClient
  getIt.registerLazySingleton(
      () => ApiClient()); // Initialize with your base URL

  // Register your repositories
  getIt.registerLazySingleton<UserRepositories>(
      () => UserRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<LeaderboardRepositories>(
      () => LeaderboardRepositoryImpl(getIt<ApiClient>()));
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<ApiClient>(), getIt<SharedPreferencesService>())); // Example

  // Register your providers
  getIt.registerChangeNotifier(() => AuthProvider(getIt<UserRepositories>()));
  getIt
      .registerChangeNotifier(() => ProfileProvider(getIt<UserRepositories>()));
  getIt.registerChangeNotifier(
      () => LeaderboardProvider(getIt<LeaderboardRepositories>()));
  getIt.registerChangeNotifier(() => ThemeProvider());
  getIt.registerLazySingleton(() => AppRouter());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  setupDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
            create: (_) => getIt<ThemeProvider>()),
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider<ProfileProvider>(
            create: (_) => getIt<ProfileProvider>()),
        ChangeNotifierProvider<LeaderboardProvider>(
            create: (_) => getIt<LeaderboardProvider>()),
        Provider<AppRouter>(create: (_) => getIt<AppRouter>()),
      ],
      child:
          const CampusPulseChallengeApp(), // Using the app widget with GoRouter
    ),
  );
}
