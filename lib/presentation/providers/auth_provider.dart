// *** lib/presentation/providers/auth_provider.dart ***
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/entities/user.dart';
import '../../core/error/failures.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/usecases/update_user_faculty_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final UpdateUserFacultyUseCase _updateUserFacultyUseCase;
  final AuthRepository _authRepository;

  User? _currentUser;
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
    required UpdateUserFacultyUseCase updateUserFacultyUseCase,
    required AuthRepository authRepository,
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _updateUserFacultyUseCase = updateUserFacultyUseCase,
        _authRepository = authRepository;

  // Method to handle sign up
  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
    required UserRole role,
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
        _currentUser = null;
        signedUpUser = null;
      },
      (user) {
        _currentUser = user;
        _errorMessage = null;
        signedUpUser = user;
      },
    );

    _isLoading = false;
    notifyListeners();
    return signedUpUser;
  }

  // Method to handle sign in
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
        _currentUser = user;
        _errorMessage = null;
        authenticatedUser = user;
      },
    );

    _isLoading = false;
    notifyListeners();
    return authenticatedUser;
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
      },
      (user) {
        if (_currentUser?.id == user.id) {
          _currentUser = user;
        }
        _errorMessage = null;
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
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
    return _currentUser != null &&
        _currentUser!.role == UserRole.user &&
        (_currentUser!.facultyId == null || _currentUser!.facultyId!.isEmpty);
  }
}
