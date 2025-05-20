import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import 'package:dartz/dartz.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/entities/user.dart';
import '../../core/error/failures.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/usecases/update_user_faculty_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
// Import the Riverpod providers for use cases and repositories
import '../../domain/usecases/get_current_user_usecase.dart'; // Assuming you have this use case

// Define the AuthState class to hold all authentication-related state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final String?
      selectedFaculty; // This might be better as a local UI state in FacultySelectionScreen

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.selectedFaculty,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    String? selectedFaculty,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Nullable, so pass null explicitly to clear
      selectedFaculty: selectedFaculty ?? this.selectedFaculty,
    );
  }
}

// ========================================================================
// AUTH NOTIFIER (RIVERPOD STATE NOTIFIER)
// Manages authentication state and logic using Riverpod.
// ========================================================================
class AuthNotifier extends StateNotifier<AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final UpdateUserFacultyUseCase _updateUserFacultyUseCase;
  final AuthRepository _authRepository; // For signOut and getCurrentUser
  final GetCurrentUserUseCase _getCurrentUserUseCase; // For initial check

  AuthNotifier({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required UpdateUserFacultyUseCase updateUserFacultyUseCase,
    required AuthRepository authRepository,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _updateUserFacultyUseCase = updateUserFacultyUseCase,
        _authRepository = authRepository,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(AuthState()); // Initial state: no user, not loading

  // Method to handle sign up
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final params = SignUpParams(
      email: email,
      password: password,
      username: username,
      role: role,
    );

    final result = await _signUpUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
          user: null,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          user: user,
        );
      },
    );
  }

  // Method to handle sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final signInResult =
        await _signInUseCase(SignInParams(email: email, password: password));

    signInResult.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
          user: null,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          user: user,
        );
      },
    );
  }

  // New method to update user's faculty
  Future<bool> updateUserFaculty({
    required String userId,
    required String facultyId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final params =
        UpdateUserFacultyParams(userId: userId, facultyId: facultyId);
    final result = await _updateUserFacultyUseCase(params);

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (user) {
        // Only update the current user if the ID matches
        if (state.user?.id == user.id) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: null,
            user: user,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: null,
          );
        }
        success = true;
      },
    );
    return success;
  }

  // Method to sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          user: null, // Clear current user on sign out
        );
      },
    );
  }

  // Method to check initial authentication status
  Future<void> checkInitialAuthStatus() async {
    state = state.copyWith(
        isLoading: true, errorMessage: null); // Set loading for initial check
    final result = await _getCurrentUserUseCase.call(); // Use the use case

    result.fold(
      (failure) {
        print('Error checking auth status: ${_mapFailureToMessage(failure)}');
        state = state.copyWith(
          isLoading: false,
          user: null,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          errorMessage: null,
        );
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message ?? 'An unexpected error occurred.';
  }

  // Helper method to check if the current user is an admin
  bool isAdmin() {
    return state.user != null && state.user!.role == UserRole.admin;
  }

  // Helper method to get the current user's role
  UserRole? getUserRole() {
    return state.user?.role;
  }

  // Add method to check if user needs to select faculty
  bool requiresFacultySelection() {
    return state.user != null &&
        state.user!.role == UserRole.user &&
        (state.user!.facultyId == null || state.user!.facultyId!.isEmpty);
  }

  // Method to update selected faculty (local UI state, not persisted)
  void selectFaculty(String faculty) {
    state = state.copyWith(selectedFaculty: faculty);
  }
}

// ========================================================================
// RIVERPOD PROVIDER DEFINITIONS
// ========================================================================

// You'll need to define providers for your use cases and repositories if you haven't already
// Example:
// final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(...));
// final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) => SignUpUseCase(authRepository: ref.watch(authRepositoryProvider)));
// final signInUseCaseProvider = Provider<SignInUseCase>((ref) => SignInUseCase(authRepository: ref.watch(authRepositoryProvider)));
// final updateUserFacultyUseCaseProvider = Provider<UpdateUserFacultyUseCase>((ref) => UpdateUserFacultyUseCase(userRepository: ref.watch(userRepositoryProvider)));
// final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) => GetCurrentUserUseCase(userRepository: ref.watch(userRepositoryProvider)));

// The main AuthProvider for Riverpod
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Ensure these dependencies are also defined as Riverpod providers
  final signUpUseCase = ref.watch(signUpUseCaseProvider);
  final signInUseCase = ref.watch(signInUseCaseProvider);
  final updateUserFacultyUseCase = ref.watch(updateUserFacultyUseCaseProvider);
  final authRepository = ref.watch(
      authRepositoryProvider); // Assuming AuthRepository is a Riverpod provider
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);

  return AuthNotifier(
    signUpUseCase: signUpUseCase,
    signInUseCase: signInUseCase,
    updateUserFacultyUseCase: updateUserFacultyUseCase,
    authRepository: authRepository,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
});

// Helper provider to directly expose the current user for simpler watching
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider.select((state) => state.user));
});

// Helper provider to directly expose the loading state
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((state) => state.isLoading));
});

// Helper provider to directly expose the error message
final authErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(authProvider.select((state) => state.errorMessage));
});

// Helper provider to directly expose if faculty selection is required
final requiresFacultySelectionProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((state) =>
      state.user != null &&
      state.user!.role == UserRole.user &&
      (state.user!.facultyId == null || state.user!.facultyId!.isEmpty)));
});
