import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'core/navigation/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'domain/repositories/user_repositories.dart'; // Corrected import
import 'data/repositories/user_repository_impl.dart'; // Corrected import
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'data/repositories/leaderboard_repository_impl.dart'; // Corrected import
import 'package:final_project/domain/repositories/leaderboard_repositories.dart'; // Corrected import
import 'presentation/providers/leaderboard_provider.dart';
import 'data/datasources/remote/api_client.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/sign_up_usecase.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource_impl.dart'
    as auth_remote_impl; // Add a prefix

final getIt = GetIt.instance;

void setupDependencies() {
  // Register your ApiClient (using the concrete implementation)
  getIt.registerLazySingleton<ApiClient>(
    () => HttpApiClient(),
  );

  // Register your remote data source
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => auth_remote_impl.AuthRemoteDataSourceImpl(
        getIt<ApiClient>()), // Use the prefix
  );

  // Register your repositories
  getIt.registerLazySingleton<UserRepositories>(
    () => UserRepositoryImpl(getIt<ApiClient>()), // Corrected
  );
  getIt.registerLazySingleton<LeaderboardRepositories>(
    () => LeaderboardRepositoryImpl(getIt<ApiClient>()), // Corrected
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Register your use cases
  getIt.registerLazySingleton(
    () => SignUpUseCase(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => SignInUseCase(getIt<AuthRepository>()));

  // Register your providers
  getIt.registerFactory(() => AuthProvider(
        getIt<SignUpUseCase>(),
        getIt<SignInUseCase>(),
        getIt<AuthRepository>(),
      ));
  getIt.registerFactory(() => ProfileProvider(
        userRepository: getIt<UserRepositories>(), // Corrected
      ));
  getIt.registerFactory(
    () => LeaderboardProvider(
      leaderboardRepository: getIt<LeaderboardRepositories>(), // Corrected
    ),
  );
  getIt.registerFactory(() => ThemeProvider());
  getIt.registerLazySingleton(() => AppRouter());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      child: const CampusPulseChallengeApp(),
    ),
  );
}
