// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'app.dart';
// import 'core/theme/theme_provider.dart';
// import 'core/navigation/app_router.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:get_it/get_it.dart';
// import 'domain/repositories/user_repositories.dart';
// import 'data/repositories/user_repository_impl.dart';
// import 'presentation/providers/auth_provider.dart';
// import 'presentation/providers/profile_provider.dart';
// import 'data/repositories/leaderboard_repository_impl.dart';
// import 'package:final_project/domain/repositories/leaderboard_repositories.dart';
// import 'presentation/providers/leaderboard_provider.dart';
// import 'data/datasources/remote/api_client.dart';
// import 'domain/repositories/auth_repository.dart';
// import 'data/repositories/auth_repository_impl.dart';
// import 'domain/usecases/sign_up_usecase.dart';
// import 'domain/usecases/sign_in_usecase.dart';
// import 'data/datasources/remote/auth_remote_datasource.dart';
// import 'data/datasources/remote/auth_remote_datasource_impl.dart'
//     as auth_remote_impl;

// final getIt = GetIt.instance;

// void setupDependencies() {
//   // Register your ApiClient (using the concrete implementation)
//   getIt.registerLazySingleton<ApiClient>(
//     () => HttpApiClient(),
//   );

//   // Register your remote data source
//   getIt.registerLazySingleton<AuthRemoteDataSource>(
//     () => auth_remote_impl.AuthRemoteDataSourceImpl(getIt<ApiClient>()),
//     //getIt.registerLazySingleton<ApiClient>(() => ApiClient(/* any required parameters */));
//   );

//   // Register your repositories
//   getIt.registerLazySingleton<UserRepositories>(
//     () => UserRepositoryImpl(getIt<ApiClient>()),
//   );
//   getIt.registerLazySingleton<LeaderboardRepositories>(
//     () => LeaderboardRepositoryImpl(getIt<ApiClient>()),
//   );
//   getIt.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
//   );

//   // Register your use cases
//   getIt.registerLazySingleton(
//     () => SignUpUseCase(getIt<AuthRepository>()),
//   );
//   getIt.registerLazySingleton(() => SignInUseCase(getIt<AuthRepository>()));

//   // Register your providers
//   getIt.registerFactory(() => AuthProvider(
//         getIt<SignUpUseCase>(),
//         getIt<SignInUseCase>(),
//         getIt<AuthRepository>(),
//       ));
//   getIt.registerFactory(() => ProfileProvider(
//         userRepository: getIt<UserRepositories>(), // Added named parameter
//       ));
//   getIt.registerFactory(() => LeaderboardProvider(
//         leaderboardRepository:
//             getIt<LeaderboardRepositories>(), // Added named parameter
//       ));
//   getIt.registerFactory(() => ThemeProvider());
//   getIt.registerLazySingleton(() => AppRouter());
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   //await Firebase.initializeApp();

//   setupDependencies();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider<ThemeProvider>(
//             create: (_) => getIt<ThemeProvider>()),
//         ChangeNotifierProvider<AuthProvider>(
//             create: (_) => getIt<AuthProvider>()),
//         ChangeNotifierProvider<ProfileProvider>(
//             create: (_) => getIt<ProfileProvider>()),
//         ChangeNotifierProvider<LeaderboardProvider>(
//             create: (_) => getIt<LeaderboardProvider>()),
//         Provider<AppRouter>(create: (_) => getIt<AppRouter>()),
//       ],
//       child: const CampusPulseChallengeApp(),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assuming Provider is used
import 'package:go_router/go_router.dart'; // Import GoRouter

import 'core/navigation/app_router.dart'; // Your AppRouter
import 'presentation/providers/auth_provider.dart'; // Your AuthProvider
// Import necessary dependencies for AuthProvider (Use cases, Repositories, DataSources)
import 'domain/usecases/sign_up_usecase.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/datasources/remote/auth_remote_datasource_impl.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'domain/usecases/update_user_faculty_usecase.dart';
import 'domain/repositories/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Required for some plugins

  // Setup simulated backend dependency
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  final signUpUseCase = SignUpUseCase(authRepository);
  final signInUseCase = SignInUseCase(authRepository);
  final updateUserFacultyUseCase = UpdateUserFacultyUseCase(authRepository);

  runApp(
    MultiProvider( // Or whatever your provider setup is (e.g., Provider, Riverpod)
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            signUpUseCase: signUpUseCase,
            signInUseCase: signInUseCase,
            updateUserFacultyUseCase: updateUserFacultyUseCase,
            authRepository: authRepository,
          )..checkInitialAuthStatus(), // Check initial auth status
        ),
        // ... other providers (e.g., for leaderboard, quests)
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.router,
      title: 'Campus Pulse',
      // theme: AppTheme.lightTheme, // Assuming you have a theme
      debugShowCheckedModeBanner: false, // Set to true for debugging
    );
  }
}
*/