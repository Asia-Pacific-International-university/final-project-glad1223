// lib/presentation/providers/profile_provider.dart
import 'package:flutter/material.dart';
import '../../domain/repositories/user_repositories.dart'; // Corrected import
import '../../domain/entities/user.dart';
import '../../core/error/failures.dart';
//import 'package:dartz/dartz.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepositories _userRepository; // Use the interface

  ProfileProvider({required UserRepositories userRepository})
      : _userRepository = userRepository;

  User? _user;
  User? get user => _user;

  Failure? _failure;
  Failure? get failure => _failure;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = ''; // Add errorMessage
  String get errorMessage => _errorMessage; // Add errorMessage getter

  Future<void> getUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = ''; // Reset errorMessage on new request
    notifyListeners();
    final result = await _userRepository.getUser(userId);
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        _errorMessage = failure.message; // Populate errorMessage
        notifyListeners();
      },
      (user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Add other profile-related methods here (e.g., updateProfile)
}
