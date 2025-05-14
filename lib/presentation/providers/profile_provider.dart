import 'package:flutter/material.dart';
import '../../domain/entities/user.dart'; // Assuming you have a User entity
import 'package:final_project/domain/repositories/user_repositories.dart'; // Assuming you have a UserRepository
import '../../core/error/failures.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  ProfileProvider(this._userRepository);

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _userRepository
        .getCurrentUser(); // Method to get current user profile
    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
      },
      (user) {
        _isLoading = false;
        _user = user;
        notifyListeners();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred.';
      case CacheFailure:
        return 'Failed to load cached data.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
