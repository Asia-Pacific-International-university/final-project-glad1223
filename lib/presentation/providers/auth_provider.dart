// *** File: lib/presentation/providers/auth_provider.dart ***

import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/failures.dart';

class AuthProvider extends ChangeNotifier {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final AuthRepository _authRepository;

  AuthProvider(this._signUpUseCase, this._signInUseCase,
      this._authRepository); // Updated constructor

  User? _user;
  User? get user => _user;

  String? _selectedFaculty;
  String? get selectedFaculty => _selectedFaculty;
  void selectFaculty(String faculty) {
    _selectedFaculty = faculty;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> signUp(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    if (_selectedFaculty == null) {
      _errorMessage = 'Please select a faculty.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final result = await _signUpUseCase(SignUpParams(
      username: username, // Assuming your SignUpParams now includes username
      email: email,
      password: password,
      faculty: _selectedFaculty!,
    ));

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        // Optionally navigate to home screen
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result =
        await _signInUseCase(SignInParams(email: email, password: password));

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        // Optionally navigate to home screen
      },
    );
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        _user = null;
        _isLoading = false;
        notifyListeners();
        // Optionally navigate to login screen
      },
    );
  }

  Future<void> checkAuthStatus() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) {
        // Handle potential errors, but for initial check, might just leave user as null
      },
      (user) {
        _user = user;
        notifyListeners();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    // Implement your failure to message mapping here
    return failure.message ?? 'An unexpected error occurred.';
  }
}
