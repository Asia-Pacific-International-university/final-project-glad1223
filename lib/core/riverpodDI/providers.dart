import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart'; // For DatabaseHelper dependency
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:firebase_messaging/firebase_messaging.dart'; // Import FirebaseMessaging

// Core
import '../error/failures.dart'; // Ensure Failure is defined here or imported
import '../services/location_service.dart';
import '../services/camera_service.dart';
import 'package:final_project/data/datasources/local/shared_preferences_service.dart'; // Import the SharedPreferencesService
import '../services/notification_service.dart'; // Import the NotificationService

// Data - Datasources
import '../../data/datasources/remote/auth_remote_datasource.dart'; // Ensure this defines AuthRemoteDataSource interface
import '../../data/datasources/remote/auth_remote_datasource_impl.dart'; // This defines AuthRemoteDataSourceImpl
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
import '../../domain/repositories/user_repositories.dart'; // Ensure this defines 'abstract class UserRepository'
import '../../domain/repositories/leaderboard_repositories.dart'; // Ensure this defines 'abstract class LeaderboardRepository'
import '../../domain/repositories/quest_repository.dart';

// Domain - Services
import 'package:final_project/domain/services/quest_submision_service.dart'; // Corrected spelling

// Domain - Use Cases
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import 'package:final_project/domain/usecases/update_faculty_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_points_usecase.dart';
import '../../domain/usecases/add_user_badges_usecase.dart';
import '../../domain/usecases/get_active_quest_usecase.dart';
import '../../domain/usecases/submit_trivia_answer_usecase.dart';
import '../../domain/usecases/submit_location_answer_usecase.dart';
import '../../domain/usecases/submit_photo_answer_usecase.dart';
import '../../domain/usecases/submit_poll_vote_usecase.dart';
import '../../domain/usecases/submit_mini_puzzle_answer_usecase.dart';
// FIX: Hide specific params from the base use case import if they are also defined there
// This prevents ambiguous_import errors.
import '../../domain/usecases/submit_quest_answer_usecase.dart'
    hide
        SubmitMiniPuzzleAnswerParams,
        SubmitPollVoteParams,
        SubmitTriviaAnswerParams,
        SubmitLocationAnswerParams,
        SubmitPhotoAnswerParams;

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

final sharedPreferencesServiceProvider =
    Provider<SharedPreferencesService>((ref) {
  return SharedPreferencesService(); // Returns the singleton instance
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final geolocator = ref.watch(geolocatorPlatformProvider);
  return LocationService(geolocator: geolocator);
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  final imagePicker = ref.watch(imagePickerProvider);
  return CameraService(imagePicker: imagePicker);
});

final firebaseMessagingProvider =
    Provider<FirebaseMessaging>((ref) => FirebaseMessaging.instance);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firebaseMessaging = ref.watch(firebaseMessagingProvider);
  return NotificationService(firebaseMessaging: firebaseMessaging);
});

// ========================================================================
// DATA SOURCE PROVIDERS (REMOTE)
// ========================================================================

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  // Constructor needs to accept 'firestore' as a named parameter
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
// DATA SOURCE PROVIDERS (LOCAL - SQLite & SharedPreferences)
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

final userRepositoryProvider = Provider<UserRepository>((ref) {
  // FIX: Type changed to UserRepository
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  return UserRepositoryImpl(
      remoteDataSource: remoteDataSource, localDataSource: localDataSource);
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepositories>((ref) {
  // FIX: Type changed to LeaderboardRepository
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
  final userRepository = ref.watch(userRepositoryProvider);
  return QuestSubmissionService(
      questRepository: questRepository, userRepository: userRepository);
});

// ========================================================================
// USE CASE PROVIDERS
// ========================================================================

// Auth Use Cases
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  return SignUpUseCase(authRepository: authRepo, userRepository: userRepo);
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  return SignInUseCase(authRepository: authRepo, userRepository: userRepo);
});

final updateAuthUserFacultyUseCaseProvider =
    Provider<UpdateUserFacultyUseCase>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  // FIX: Ensure UpdateUserFacultyUseCase constructor accepts 'userRepository' as a named parameter
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

// Quest Submission Use Cases
final submitTriviaAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  // FIX: Ensure SubmitTriviaAnswerUseCase extends SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams>
  return SubmitTriviaAnswerUseCase(submissionService: submissionService);
});

final submitLocationAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitLocationAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  // FIX: Ensure SubmitLocationAnswerUseCase extends SubmitQuestAnswerUseCase<SubmitLocationAnswerParams>
  return SubmitLocationAnswerUseCase(submissionService: submissionService);
});

final submitPhotoAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitPhotoAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  // FIX: Ensure SubmitPhotoAnswerUseCase extends SubmitQuestAnswerUseCase<SubmitPhotoAnswerParams>
  return SubmitPhotoAnswerUseCase(submissionService: submissionService);
});

final submitPollVoteUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitPollVoteParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  // FIX: Ensure SubmitPollVoteUseCase extends SubmitQuestAnswerUseCase<SubmitPollVoteParams>
  return SubmitPollVoteUseCase(submissionService: submissionService);
});

final submitMiniPuzzleAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase<SubmitMiniPuzzleAnswerParams>>((ref) {
  final submissionService = ref.watch(questSubmissionServiceProvider);
  // FIX: Ensure SubmitMiniPuzzleAnswerUseCase extends SubmitQuestAnswerUseCase<SubmitMiniPuzzleAnswerParams>
  return SubmitMiniPuzzleAnswerUseCase(submissionService: submissionService);
});
