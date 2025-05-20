import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart'; // For DatabaseHelper dependency

// Core
import '../error/failures.dart'; // Ensure Failure is defined here or imported
import '../services/location_service.dart';
import '../services/camera_service.dart';

// Data - Datasources
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource_impl.dart';
import '../../data/datasources/remote/leaderboard_remote_datasource.dart';
import '../../data/datasources/remote/leaderboard_remote_datasource_impl.dart';
import '../../data/datasources/remote/quest_remote_datasource.dart';
import '../../data/datasources/remote/quest_remote_datasource_impl.dart';
import '../../data/datasources/local/user_local_datasource.dart';
import '../../data/datasources/local/user_local_datasource_impl.dart';
import '../../data/datasources/local/quest_local_datasource.dart';
import '../../data/datasources/local/quest_local_datasource_impl.dart';
import '../../data/datasources/local/faculty_local_datasource.dart';
import '../../data/datasources/local/faculty_local_datasource_impl.dart';
import '../../data/datasources/local/database_helper.dart'; // Your SQLite helper

// Data - Repositories
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../data/repositories/quest_repository_impl.dart';

// Domain - Repositories (Interfaces)
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repositories.dart';
import '../../domain/repositories/leaderboard_repositories.dart';
import '../../domain/repositories/quest_repository.dart';

// Domain - Services
import '../../domain/services/quest_submission_service.dart';

// Domain - Use Cases
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/update_user_faculty_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_points_usecase.dart';
import '../../domain/usecases/add_user_badges_usecase.dart';
import '../../domain/usecases/get_active_quest_usecase.dart';
import '../../domain/usecases/submit_trivia_answer_usecase.dart';
import '../../domain/usecases/submit_location_answer_usecase.dart';
import '../../domain/usecases/submit_photo_answer_usecase.dart';
import '../../domain/usecases/submit_poll_vote_usecase.dart'; // New
import '../../domain/usecases/submit_mini_puzzle_answer_usecase.dart'; // New
import '../../domain/usecases/submit_quest_answer_usecase.dart'; // Base use case

// ========================================================================
// CORE SERVICE PROVIDERS
// ========================================================================

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>(
    (ref) => firebase_auth.FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final geolocatorPlatformProvider =
    Provider<GeolocatorPlatform>((ref) => GeolocatorPlatform.instance);

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final databaseHelperProvider =
    Provider<DatabaseHelper>((ref) => DatabaseHelper());

final locationServiceProvider = Provider<LocationService>((ref) {
  final geolocator = ref.watch(geolocatorPlatformProvider);
  return LocationService(geolocator: geolocator);
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  final imagePicker = ref.watch(imagePickerProvider);
  return CameraService(imagePicker: imagePicker);
});

// ========================================================================
// DATA SOURCE PROVIDERS (REMOTE)
// ========================================================================

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRemoteDataSourceImpl(
      firebaseAuth: firebaseAuth, firestore: firestore);
});

final leaderboardRemoteDataSourceProvider =
    Provider<LeaderboardRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return LeaderboardRemoteDataSourceImpl(firestore: firestore);
});

final questRemoteDataSourceProvider = Provider<QuestRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return QuestRemoteDataSourceImpl(client: client);
});

// ========================================================================
// DATA SOURCE PROVIDERS (LOCAL - SQLite)
// ========================================================================

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return UserLocalDataSourceImpl(dbHelper);
});

final questLocalDataSourceProvider = Provider<QuestLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return QuestLocalDataSourceImpl(dbHelper);
});

final facultyLocalDataSourceProvider = Provider<FacultyLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return FacultyLocalDataSourceImpl(dbHelper);
});

// ========================================================================
// REPOSITORY PROVIDERS
// ========================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

final userRepositoryProvider = Provider<UserRepositories>((ref) {
  final remoteDataSource = ref.watch(
      authRemoteDataSourceProvider); // Assuming AuthRemoteDataSource handles user profile
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  return UserRepositoryImpl(
      remoteDataSource: remoteDataSource, localDataSource: localDataSource);
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepositories>((ref) {
  final remoteDataSource = ref.watch(leaderboardRemoteDataSourceProvider);
  final localDataSource = ref.watch(facultyLocalDataSourceProvider);
  return LeaderboardRepositoryImpl(
      remoteDataSource: remoteDataSource, localDataSource: localDataSource);
});

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  final remoteDataSource = ref.watch(questRemoteDataSourceProvider);
  final localDataSource = ref.watch(questLocalDataSourceProvider);
  return QuestRepositoryImpl(
      remoteDataSource: remoteDataSource, localDataSource: localDataSource);
});

// ========================================================================
// DOMAIN SERVICE PROVIDERS
// ========================================================================

final questSubmissionServiceProvider = Provider<QuestSubmissionService>((ref) {
  final questRepository = ref.watch(questRepositoryProvider);
  final userRepository = ref.watch(
      userRepositoryProvider); // QuestSubmissionService needs UserRepository to update points/badges
  return QuestSubmissionService(
      questRepository: questRepository, userRepository: userRepository);
});

// ========================================================================
// USE CASE PROVIDERS
// ========================================================================

// Auth Use Cases
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo =
      ref.watch(userRepositoryProvider); // SignUp needs to create user profile
  return SignUpUseCase(authRepository: authRepo, userRepository: userRepo);
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo =
      ref.watch(userRepositoryProvider); // SignIn needs to fetch user profile
  return SignInUseCase(authRepository: authRepo, userRepository: userRepo);
});

final updateAuthUserFacultyUseCaseProvider =
    Provider<UpdateUserFacultyUseCase>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return UpdateUserFacultyUseCase(userRepository: userRepo);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return GetCurrentUserUseCase(userRepository: userRepo);
});

// User Profile Use Cases
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return GetUserProfileUseCase(userRepository: userRepo);
});

final updateUserPointsUseCaseProvider =
    Provider<UpdateUserPointsUseCase>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return UpdateUserPointsUseCase(userRepository: userRepo);
});

final addUserBadgesUseCaseProvider = Provider<AddUserBadgesUseCase>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return AddUserBadgesUseCase(userRepository: userRepo);
});

// Quest Use Cases
final getActiveQuestUseCaseProvider = Provider<GetActiveQuestUseCase>((ref) {
  final repository = ref.watch(questRepositoryProvider);
  return GetActiveQuestUseCase(questRepository: repository);
});

// Quest Submission Use Cases (depend on QuestSubmissionService)
final submitTriviaAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  return SubmitTriviaAnswerUseCase(submissionService: submissionService);
});

final submitLocationAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitLocationAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  return SubmitLocationAnswerUseCase(submissionService: submissionService);
});

final submitPhotoAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitPhotoAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  return SubmitPhotoAnswerUseCase(submissionService: submissionService);
});

final submitPollVoteUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitPollVoteParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  return SubmitPollVoteUseCase(submissionService: submissionService);
});

final submitMiniPuzzleAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitMiniPuzzleAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  return SubmitMiniPuzzleAnswerUseCase(submissionService: submissionService);
});
