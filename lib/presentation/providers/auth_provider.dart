// *** File: lib/presentation/providers/auth_provider.dart ***
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart'; // For Either
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart'; // Assuming you have this
import '../../domain/entities/user.dart';
import '../../core/error/failures.dart';
import '../../core/constants/app_constants.dart'; // Import role enum
import '../../data/models/user_model.dart'; // Import UserModel for placeholder
import '../../domain/usecases/update_user_faculty_usecase.dart'; // Import the update faculty use case
import '../../domain/repositories/auth_repository.dart'; // Import AuthRepository for signOut and getCurrentUser

class AuthProvider with ChangeNotifier {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase; // Use this for logging in existing users
  final UpdateUserFacultyUseCase _updateUserFacultyUseCase; // New use case
  final AuthRepository
      _authRepository; // Add AuthRepository for signOut and getCurrentUser

  User? _currentUser; // Store the currently logged-in user
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _selectedFaculty;
  String? get selectedFaculty => _selectedFaculty;
  void selectFaculty(String faculty) {
    _selectedFaculty = faculty;
    notifyListeners();
  }

  AuthProvider({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required UpdateUserFacultyUseCase
        updateUserFacultyUseCase, // Inject the new use case
    required AuthRepository authRepository, // Initialize AuthRepository
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _updateUserFacultyUseCase = updateUserFacultyUseCase,
        _authRepository = authRepository;

  // Method to handle sign up
  Future<User?> signUp({
    // Return User? to indicate success/failure
    required String email,
    required String password,
    required String username,
    required UserRole role, // FacultyId removed from input
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final params = SignUpParams(
      email: email,
      password: password,
      username: username,
      role: role,
    );

    final result = await _signUpUseCase(params);

    User? signedUpUser;

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _currentUser = null; // Clear current user on failure
        signedUpUser = null;
      },
      (user) {
        _currentUser =
            user; // Store the successfully signed-up user (initially without faculty)
        _errorMessage = null; // Clear any previous errors on success
        signedUpUser = user;
      },
    );

    _isLoading = false;
    notifyListeners();
    return signedUpUser; // Return the user or null
  }

  // Method to handle sign in (Crucially, this must also retrieve the user's role and faculty)
  Future<User?> signIn(
      {required String email, required String password}) async {
    // Return User?
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Use the SignInUseCase with SignInParams
    final signInResult =
        await _signInUseCase(SignInParams(email: email, password: password));

    User? authenticatedUser;

    signInResult.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _currentUser = null;
        authenticatedUser = null;
      },
      (user) {
        _currentUser =
            user; // Store the logged-in user (who now has a role and facultyId/Name)
        _errorMessage = null;
        authenticatedUser = user;
      },
    );

    _isLoading = false;
    notifyListeners();
    return authenticatedUser; // Return the user or null
  }

  // New method to update user's faculty
  Future<bool> updateUserFaculty({
    required String userId,
    required String facultyId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final params =
        UpdateUserFacultyParams(userId: userId, facultyId: facultyId);
    final result = await _updateUserFacultyUseCase(params);

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        // If updating current user, need to decide how to handle state on failure
        // For simplicity, we just show an error message here.
      },
      (user) {
        // Update the current user in the provider's state with the newly updated user
        // This ensures the UI reacts to the faculty change.
        if (_currentUser?.id == user.id) {
          _currentUser = user;
        }
        _errorMessage = null; // Clear any previous errors on success
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success; // Indicate if the update was successful
  }

  // Method to sign out
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      (_) {
        _currentUser = null;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkInitialAuthStatus() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) {
        // Handle potential errors, but for initial check, might just leave user as null
        print('Error checking auth status: ${_mapFailureToMessage(failure)}');
      },
      (user) {
        _currentUser = user;
        notifyListeners();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message ?? 'An unexpected error occurred.';
  }

  // Helper method to check if the current user is an admin
  bool isAdmin() {
    return _currentUser != null && _currentUser!.role == UserRole.admin;
  }

  // Helper method to get the current user's role
  UserRole? getUserRole() {
    return _currentUser?.role;
  }

  // Add method to check if user needs to select faculty
  bool requiresFacultySelection() {
    // A user needs faculty selection if they are logged in, are a regular user,
    // AND their facultyId is empty/null.
    return _currentUser != null &&
        _currentUser!.role == UserRole.user &&
        (_currentUser!.facultyId == null ||
            _currentUser!.facultyId!.isEmpty); // Check the faculty ID field
  }

  // Potential method to check initial auth state on app start
  // This would typically involve checking stored tokens or calling a 'getCurrentUser' backend endpoint
  // Future<void> checkAuthStatus() async {
  //   _isLoading = true;
  //   // Simulate checking for a logged-in user
  //   await Future.delayed(const Duration(seconds: 0)); // Quick check
  //   // In a real app, fetch user from local storage or backend
  //   // If user found, set _currentUser = user;
  //   _isLoading = false;
  //   notifyListeners();
  // }

  // ... potentially other methods related to auth state
}

// // *** File: lib/presentation/providers/auth_provider.dart ***
// import 'package:flutter/material.dart';
// import '../../domain/entities/user.dart';
// import '../../domain/usecases/sign_in_usecase.dart';
// import '../../domain/usecases/sign_up_usecase.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../../core/error/failures.dart';

// class AuthProvider extends ChangeNotifier {
//   final SignUpUseCase _signUpUseCase;
//   final SignInUseCase _signInUseCase;
//   final AuthRepository _authRepository;

//   AuthProvider(
//     this._signUpUseCase,
//     this._signInUseCase,
//     this._authRepository,
//   ); // Updated constructor

//   User? _user;
//   User? get user => _user;

//   String? _selectedFaculty;
//   String? get selectedFaculty => _selectedFaculty;
//   void selectFaculty(String faculty) {
//     _selectedFaculty = faculty;
//     notifyListeners();
//   }

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _errorMessage = '';
//   String get errorMessage => _errorMessage;

//   Future<void> signUp(String username, String email, String password) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     if (_selectedFaculty == null) {
//       _errorMessage = 'Please select a faculty.';
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     final result = await _signUpUseCase(SignUpParams(
//       username: username,
//       email: email,
//       password: password,
//       faculty: _selectedFaculty!,
//     ));

//     result.fold(
//       (failure) {
//         _errorMessage = _mapFailureToMessage(failure);
//         _isLoading = false;
//         notifyListeners();
//       },
//       (user) {
//         _user = user;
//         _isLoading = false;
//         notifyListeners();
//         // Optionally navigate to home screen
//       },
//     );
//   }

//   Future<void> signIn(String email, String password) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     final result =
//         await _signInUseCase(SignInParams(email: email, password: password));

//     result.fold(
//       (failure) {
//         _errorMessage = _mapFailureToMessage(failure);
//         _isLoading = false;
//         notifyListeners();
//       },
//       (user) {
//         _user = user;
//         _isLoading = false;
//         notifyListeners();
//         // Optionally navigate to home screen
//       },
//     );
//   }

//   Future<void> signOut() async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     final result = await _authRepository.signOut();

//     result.fold(
//       (failure) {
//         _errorMessage = _mapFailureToMessage(failure);
//         _isLoading = false;
//         notifyListeners();
//       },
//       (_) {
//         _user = null;
//         _isLoading = false;
//         notifyListeners();
//         // Optionally navigate to login screen
//       },
//     );
//   }

//   Future<void> checkInitialAuthStatus() async {
//     // Changed method name
//     final result = await _authRepository.getCurrentUser();
//     result.fold(
//       (failure) {
//         // Handle potential errors, but for initial check, might just leave user as null
//       },
//       (user) {
//         _user = user;
//         notifyListeners();
//       },
//     );
//   }

//   String _mapFailureToMessage(Failure failure) {
//     // Implement your failure to message mapping here
//     return failure.message ?? 'An unexpected error occurred.';
//   }
// }
