import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import 'package:dartz/dartz.dart';
import '../../domain/repositories/user_repositories.dart';
import '../../domain/entities/user.dart';
import '../../core/error/failures.dart';
import '../../domain/usecases/get_user_profile_usecase.dart'; // Assuming you have this use case
import '../../domain/usecases/update_user_points_usecase.dart'; // Assuming you have this use case
import '../../domain/usecases/add_user_badges_usecase.dart'; // Assuming you have this use case

// Define the ProfileState class to hold all profile-related state
class ProfileState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Nullable, so pass null explicitly to clear
    );
  }
}

// ========================================================================
// PROFILE NOTIFIER (RIVERPOD STATE NOTIFIER)
// Manages user profile state and logic using Riverpod.
// ========================================================================
class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserPointsUseCase _updateUserPointsUseCase; // New
  final AddUserBadgesUseCase _addUserBadgesUseCase; // New

  ProfileNotifier({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserPointsUseCase updateUserPointsUseCase,
    required AddUserBadgesUseCase addUserBadgesUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _updateUserPointsUseCase = updateUserPointsUseCase,
        _addUserBadgesUseCase = addUserBadgesUseCase,
        super(ProfileState()); // Initial state

  Future<void> getUserProfile(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getUserProfileUseCase.call(userId); // Call use case

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          user: null,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          errorMessage: null,
        );
        _awardInitialBadges(); // Award badges after loading the user
      },
    );
  }

  // Simple logic to award initial badges based on total points
  void _awardInitialBadges() {
    if (state.user != null) {
      final badges = <String>[
        ...state.user!.badges
      ]; // Start with existing badges
      bool changed = false;

      if (state.user!.totalPoints >= 10 &&
          !badges.contains('Good Job. Beginner Badge')) {
        badges.add('Good Job. Beginner Badge');
        changed = true;
      }
      if (state.user!.totalPoints >= 50 &&
          !badges.contains('Great Job. Master Badge')) {
        badges.add('Great Job. Master Badge');
        changed = true;
      }
      if (state.user!.totalPoints >= 100 &&
          !badges.contains('Best Job. Pro Badge')) {
        badges.add('Best Job. Pro Badge');
        changed = true;
      }

      if (changed) {
        // Update user in state. This doesn't persist to backend automatically.
        // In a real app, you would likely call a use case to persist these badge updates.
        state = state.copyWith(user: state.user!.copyWith(badges: badges));
        // You would then call a use case like:
        // _addUserBadgesUseCase.call(AddUserBadgesParams(userId: state.user!.id, badgesToAdd: badges.where((b) => !state.user!.badges.contains(b)).toList()));
      }
    }
  }

  // Example: Method to update user's points (calling a use case)
  Future<bool> updateUserPoints(String userId, int newPoints) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _updateUserPointsUseCase.call(
      UpdateUserPointsParams(userId: userId, newTotalPoints: newPoints),
    );

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (updatedUser) {
        state = state.copyWith(
          isLoading: false,
          user: updatedUser, // Update the user in state with the new points
          errorMessage: null,
        );
        success = true;
      },
    );
    return success;
  }

  // Example: Method to add badges (calling a use case)
  Future<bool> addBadges(String userId, List<String> badgesToAdd) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _addUserBadgesUseCase.call(
      AddUserBadgesParams(userId: userId, badgesToAdd: badgesToAdd),
    );

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (updatedUser) {
        state = state.copyWith(
          isLoading: false,
          user: updatedUser, // Update the user in state with the new badges
          errorMessage: null,
        );
        success = true;
      },
    );
    return success;
  }
}

// ========================================================================
// RIVERPOD PROVIDER DEFINITIONS
// ========================================================================

// The main ProfileProvider for Riverpod
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  // Ensure these dependencies are also defined as Riverpod providers
  final getUserProfileUseCase = ref.watch(getUserProfileUseCaseProvider);
  final updateUserPointsUseCase =
      ref.watch(updateUserPointsUseCaseProvider); // Assuming this exists
  final addUserBadgesUseCase =
      ref.watch(addUserBadgesUseCaseProvider); // Assuming this exists

  return ProfileNotifier(
    getUserProfileUseCase: getUserProfileUseCase,
    updateUserPointsUseCase: updateUserPointsUseCase,
    addUserBadgesUseCase: addUserBadgesUseCase,
  );
});

// Helper provider to directly expose the user for simpler watching
final profileUserProvider = Provider<User?>((ref) {
  return ref.watch(profileProvider.select((state) => state.user));
});

// Helper provider to directly expose the loading state
final profileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider.select((state) => state.isLoading));
});

// Helper provider to directly expose the error message
final profileErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(profileProvider.select((state) => state.errorMessage));
});
