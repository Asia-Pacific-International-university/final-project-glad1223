// *** lib/data/datasources/remote/auth_remote_datasource_impl.dart ***
import 'package:http/http.dart' as http; // Example using http
import '../../../core/constants/app_constants.dart'; // Import the role enum
import '../../../core/error/exceptions.dart'; // Assuming you have custom exceptions
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';
import 'api_client.dart'; // Assuming you have an API client
import 'dart:math';
import 'dart:async'; // For Completer to simulate async operations

// In-memory storage for simulated users
final List<UserModel> _simulatedUsers = [];
// In-memory storage for simulated passwords (INSECURE - Simulation ONLY)
final Map<String, String> _simulatedPasswords = {};

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient? apiClient; // Use your API client (nullable for simulation)

  AuthRemoteDataSourceImpl({this.apiClient}) {
    // Initialize with predefined users only once during the app's lifecycle
    if (_simulatedUsers.isEmpty && apiClient == null) {
      _addPredefinedUsers();
    }
    print(
        "AuthRemoteDataSourceImpl initialized with API Client: ${apiClient != null}");
  }

  void _addPredefinedUsers() {
    print("Initializing with predefined users...");
    // Clear previous simulation data if any (important for hot restart during development)
    _simulatedUsers.clear();
    _simulatedPasswords.clear();

    // Define predefined users, their emails, passwords, and faculty IDs
    final predefined = [
      {
        'id': 'user_glad_admin',
        'email': 'glad@aiu.com',
        'password': '12345',
        'username': 'Glad',
        'facultyId': '',
        'totalPoints': 0,
        'badges': [],
        'role': UserRole.admin,
      },
      {
        'id': 'user_gladness',
        'email': 'gladnes@aiu.com',
        'password': '12345',
        'username': 'Gladness',
        'facultyId': AppFaculties.informationTechnology,
        'totalPoints': 150,
        'badges': ['first_quest'],
        'role': UserRole.user,
      },
      {
        'id': 'user_sisa',
        'email': 'sisa@aiu.com',
        'password': '12345',
        'username': 'Sisa',
        'facultyId': AppFaculties.businessAdministration,
        'totalPoints': 120,
        'badges': [],
        'role': UserRole.user,
      },
      {
        'id': 'user_marie',
        'email': 'marie@aiu.com',
        'password': '12345',
        'username': 'Marie',
        'facultyId': AppFaculties.science,
        'totalPoints': 180,
        'badges': ['quick_thinker'],
        'role': UserRole.user,
      },
      {
        'id': 'user_lar',
        'email': 'lar@aiu.com',
        'password': '12345',
        'username': 'Lar',
        'facultyId': AppFaculties.artsAndHumanities,
        'totalPoints': 90,
        'badges': [],
        'role': UserRole.user,
      },
    ];

    for (final userData in predefined) {
      // Create UserModel instance from the data
      final userModel = UserModel(
        id: userData['id'] as String,
        email: userData['email'] as String,
        username: userData['username'] as String,
        facultyId: userData['facultyId'] as String?, // Made nullable
        totalPoints: userData['totalPoints'] as int?, // Made nullable
        badges: userData['badges'] as List<String>?, // Made nullable
        role: userData['role'] as UserRole?, // Made nullable
      );
      // Add to our simulated storage
      _simulatedUsers.add(userModel);
      // Store password (INSECURE - Simulation ONLY)
      _simulatedPasswords[userModel.email] = userData['password'] as String;
    }
    print("Predefined users added: ${_simulatedUsers.length}");
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String? facultyId, // Accept facultyId during signup
    required UserRole role, // Accept the role
  }) async {
    print("Simulating signUp for: $email");
    if (apiClient != null) {
      // Real API call
      try {
        final response = await apiClient!.post(
          '/auth/signup', // Your backend signup endpoint
          body: {
            'email': email,
            'password': password,
            'username': username,
            'facultyId': facultyId,
            'role': role.name, // Send role as string
          },
        );

        if (response is Map<String, dynamic> && response.containsKey('id')) {
          return UserModel.fromJson(response);
        } else {
          throw ServerException('Failed to sign up: ${response.toString()}');
        }
      } on ServerException catch (e) {
        rethrow;
      } catch (e) {
        throw ServerException('Sign up failed: $e');
      }
    } else {
      // Simulation
      if (_simulatedUsers
          .any((user) => user.email.toLowerCase() == email.toLowerCase())) {
        print("Signup failed: Email already in use");
        throw EmailAlreadyInUseException(
            'The email address is already in use.'); // Throw specific exception
      }

      try {
        await Future.delayed(const Duration(seconds: 1));
        final String newUserId =
            'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
        final newUser = UserModel(
          id: newUserId,
          email: email,
          username: username,
          facultyId: facultyId, // Use provided facultyId
          totalPoints: 0,
          badges: [],
          role: role,
        );
        _simulatedUsers.add(newUser);
        _simulatedPasswords[newUser.email] = password;
        print(
            "Simulated new user signed up: ${newUser.username} (${newUser.email}) with role ${newUser.role.name}");
        print("Current simulated users: ${_simulatedUsers.length}");
        return newUser;
      } catch (e) {
        print("Simulated signup error: $e");
        if (e is AuthenticationException || e is ServerException) rethrow;
        throw ServerException('Simulated sign up failed: ${e.toString()}');
      }
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print("Simulating signIn for: $email");
    if (apiClient != null) {
      // Real API call
      try {
        final response = await apiClient!.post(
          '/auth/login', // Your backend signin endpoint
          body: {
            'email': email,
            'password': password,
          },
        );

        if (response is Map<String, dynamic> &&
            response.containsKey('id') &&
            response.containsKey('role')) {
          return UserModel.fromJson(response); // This must include the role!
        } else {
          throw AuthenticationException(
              'Failed to sign in: Invalid credentials or response format');
        }
      } on AuthenticationException catch (e) {
        rethrow;
      } catch (e) {
        throw AuthenticationException('Sign in failed: $e');
      }
    } else {
      // Simulation
      try {
        await Future.delayed(const Duration(seconds: 1));
        final user = _simulatedUsers.firstWhere(
          (user) => user.email.toLowerCase() == email.toLowerCase(),
        );
        if (_simulatedPasswords[user.email] != password) {
          print("Signin failed: Password mismatch for ${user.email}");
          throw InvalidCredentialsException(
              'Invalid email or password.'); // Password doesn't match
        }
        print("Simulated signin success for user: ${user.username}");
        return user; // Return the found user model (includes role and faculty)
      } on StateError {
        print("Signin failed: User not found for $email");
        throw InvalidCredentialsException(
            'Invalid email or password.'); // User not found
      } catch (e) {
        print("Simulated signin error: $e");
        if (e is AuthenticationException || e is ServerException) rethrow;
        throw AuthenticationException(
            'Simulated sign in failed: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> signOut() async {
    print("Simulating signOut");
    if (apiClient != null) {
      try {
        final response = await apiClient!.post('/auth/logout', body: {});
        if (response is! Map<String, dynamic> ||
            (response as Map<String, dynamic>).containsKey('error')) {
          print('Sign out might have failed: $response');
        }
        print('Sign out successful (API call)');
      } catch (e) {
        print('Sign out failed (API call): $e');
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      print('Sign out successful (simulated)');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    print("Simulating getCurrentUser");
    if (apiClient != null) {
      try {
        final response = await apiClient!
            .get('/auth/me'); // Or /auth/status, adjust based on your API
        if (response != null &&
            response is Map<String, dynamic> &&
            response.containsKey('id') &&
            response.containsKey('role')) {
          return UserModel.fromJson(response);
        }
        return null;
      } catch (e) {
        print('Error fetching current user (API call): $e');
        return null;
      }
    } else {
      // In a real scenario, you might store a session token or user ID locally
      // and use that to fetch the current user. For simulation, we don't persist sessions.
      await Future.delayed(const Duration(milliseconds: 300));
      return _simulatedUsers.isNotEmpty
          ? _simulatedUsers.first
          : null; // Return the first user as "current" for simple sim
    }
  }

  @override
  Future<UserModel> updateUserFaculty(
      {required String userId, required String facultyId}) async {
    print("Simulating update faculty for user ID: $userId to $facultyId");
    if (apiClient != null) {
      try {
        final response = await apiClient!.put(
          '/users/$userId', // Adjust your API endpoint
          body: {'facultyId': facultyId},
        );
        if (response is Map<String, dynamic> && response.containsKey('id')) {
          return UserModel.fromJson(response);
        } else {
          throw ServerException(
              'Failed to update faculty: ${response.toString()}');
        }
      } on ServerException catch (e) {
        rethrow;
      } catch (e) {
        throw ServerException('Failed to update faculty: $e');
      }
    } else {
      try {
        await Future.delayed(const Duration(seconds: 1));
        final index = _simulatedUsers.indexWhere((user) => user.id == userId);
        if (index == -1) {
          print("Update failed: User ID not found");
          throw UserNotFoundException('User with ID $userId not found.');
        }
        final oldUser = _simulatedUsers[index];
        final updatedUser = UserModel(
          id: oldUser.id,
          email: oldUser.email,
          username: oldUser.username,
          facultyId: facultyId, // Update the faculty ID
          totalPoints: oldUser.totalPoints,
          badges: oldUser.badges,
          role: oldUser.role,
        );
        _simulatedUsers[index] = updatedUser;
        print(
            "Simulated user faculty updated: ${updatedUser.username} now in ${updatedUser.facultyName}");
        return updatedUser;
      } catch (e) {
        print("Simulated update faculty error: $e");
        if (e is AuthenticationException || e is ServerException) rethrow;
        throw ServerException(
            'Simulated faculty update failed: ${e.toString()}');
      }
    }
  }

  // Add a method to get all simulated users (useful for leaderboard simulation later)
  static List<UserModel> getAllSimulatedUsers() {
    // Return a copy of the list to prevent external modification
    return List.from(_simulatedUsers);
  }
}

// // *** lib/data/datasources/remote/auth_remote_datasource_impl.dart ***
// import '../../../core/error/failures.dart';
// import '../../models/user_model.dart';
// import 'api_client.dart';
// import 'auth_remote_datasource.dart';

// class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
//   final ApiClient _apiClient;

//   AuthRemoteDataSourceImpl(this._apiClient);

//   @override
//   Future<UserModel> signIn(String email, String password) async {
//     try {
//       final response = await _apiClient
//           .post('/auth/login', body: {'email': email, 'password': password});
//       return UserModel.fromJson(response);
//     } catch (e) {
//       // Handle specific error codes and throw appropriate exceptions/Failures
//       throw ServerFailure('Login failed: ${e.toString()}');
//     }
//   }

//   @override
//   Future<UserModel> signUp(
//       String username, String email, String password, String faculty) async {
//     try {
//       final response = await _apiClient.post('/auth/signup', body: {
//         'username': username,
//         'email': email,
//         'password': password,
//         'faculty': faculty
//       });
//       return UserModel.fromJson(response);
//     } catch (e) {
//       // Handle specific error codes
//       throw ServerFailure('Signup failed: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> signOut() async {
//     try {
//       await _apiClient.post('/auth/logout',
//           body: {}); // Or however your logout API is structured
//     } catch (e) {
//       // Optionally handle logout errors
//       print('Logout failed: ${e.toString()}');
//     }
//   }

//   @override
//   Future<UserModel?> getCurrentUser() async {
//     try {
//       final response = await _apiClient
//           .get('/auth/me'); // Or /auth/status, adjust based on your API
//       if (response != null && response is Map<String, dynamic>) {
//         return UserModel.fromJson(response);
//       }
//       return null;
//     } catch (e) {
//       // If no active session, the API might return an error or null
//       return null;
//     }
//   }
// }
