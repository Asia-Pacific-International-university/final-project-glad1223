import 'package:http/http.dart'
    as http; // Import if you still need it for other API calls
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';
// import 'api_client.dart'; // ApiClient is no longer directly used here, removed if not needed elsewhere
import 'dart:async';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // final ApiClient? apiClient; // Removed if not used
  final firebase_auth.FirebaseAuth _firebaseAuth; // Now a dependency
  final FirebaseFirestore _firestore; // Now a dependency

  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    // this.apiClient // Removed if not used
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;
  // {
  //   print("AuthRemoteDataSourceImpl initialized with API Client: ${apiClient != null}");
  // }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String? facultyId,
    required UserRole role,
  }) async {
    print(
        "signUpWithEmailAndPassword called with email: $email, username: $username, role: $role, facultyId: $facultyId");
    try {
      // 1. Create user with Firebase Authentication
      final firebaseUserCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = firebaseUserCredential.user;

      if (firebaseUser == null) {
        throw AuthenticationException('Firebase User is null after sign up.');
      }

      // 2. Store additional user data in Firestore
      final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);
      await userDocRef.set({
        'username': username,
        'email': email,
        'role': role.name, // Store role as string
        'facultyId': facultyId,
        'totalPoints': 0,
        'badges': [],
        // Add any other custom fields you need
      });

      // 3. Create the UserModel to return.
      final newUser = UserModel(
        id: firebaseUser.uid,
        email: email,
        username: username,
        role: role,
        facultyId: facultyId,
        totalPoints: 0,
        badges: [],
      );
      print("User signed up successfully.  Returning $newUser");
      return newUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      throw _handleFirebaseError(e);
    } catch (e) {
      // Handle other errors (e.g., Firestore errors)
      print("Error during sign up: $e");
      throw ServerException('Failed to sign up: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print("signInWithEmailAndPassword called for $email");
    try {
      // 1. Sign in with Firebase Authentication
      final firebaseUserCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = firebaseUserCredential.user;

      if (firebaseUser == null) {
        throw AuthenticationException('Failed to sign in.');
      }

      // 2. Retrieve user data from Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        throw AuthenticationException(
            'User data not found in Firestore.  This should not happen.');
      }

      final userData = userDoc.data();
      if (userData == null) {
        throw AuthenticationException("User Data was null");
      }

      // 3. Convert role string back to UserRole enum.
      UserRole userRole;
      try {
        userRole = UserRole.values.firstWhere(
            (e) => e.name == userData['role']); //userData!['role']);
      } catch (e) {
        print("Error parsing role: ${userData['role']}.  Defaulting to User");
        userRole = UserRole.user; // Default role if the stored role is invalid
      }
      // 4. Create and return the UserModel
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        username: userData['username'] ?? '', // Provide a default value if null
        role: userRole,
        facultyId: userData['facultyId'],
        totalPoints: userData['totalPoints'],
        badges: List<String>.from(userData['badges'] ?? []),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      print("Error during sign in: $e");
      throw AuthenticationException('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    print("signOut called");
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Error during sign out: $e");
      throw ServerException('Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    print("getCurrentUser called");
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    try {
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        return null; // Or throw an exception if user should always exist
      }
      final userData = userDoc.data();
      if (userData == null) {
        return null;
      }
      UserRole userRole;
      try {
        userRole =
            UserRole.values.firstWhere((e) => e.name == userData['role']);
      } catch (e) {
        print("Error getting user role, defaulting to user.");
        userRole = UserRole.user;
      }

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        username: userData['username'] ?? '',
        role: userRole,
        facultyId: userData['facultyId'],
        totalPoints: userData['totalPoints'],
        badges: List<String>.from(userData['badges'] ?? []),
      );
    } catch (e) {
      print("Error fetching current user: $e");
      return null; // Or handle the error as needed.
    }
  }

  @override
  Future<UserModel> updateUserFaculty({
    required String userId,
    required String facultyId,
  }) async {
    print("updateUserFaculty called for $userId with facultyId: $facultyId");
    try {
      // 1. Update facultyId in Firestore
      await _firestore.collection('users').doc(userId).update({
        'facultyId': facultyId,
      });

      // 2. Retrieve the updated user data from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw UserNotFoundException(
            'User with ID $userId not found in Firestore.');
      }
      final userData = userDoc.data();
      if (userData == null) {
        throw ServerException("User Data was null");
      }

      // 3. Convert role string to UserRole
      UserRole userRole;
      try {
        userRole =
            UserRole.values.firstWhere((e) => e.name == userData['role']);
      } catch (e) {
        print("Error getting user role, defaulting to user.");
        userRole = UserRole.user;
      }
      // 4. Return the updated UserModel
      return UserModel(
        id: userId,
        email: userData['email'],
        username: userData['username'],
        role: userRole,
        facultyId: facultyId, // The updated facultyId
        totalPoints: userData['totalPoints'],
        badges: List<String>.from(userData['badges'] ?? []),
      );
    } catch (e) {
      print("Error updating user faculty: $e");
      throw ServerException('Failed to update faculty: $e');
    }
  }

  // Helper function to handle Firebase Auth errors
  Exception _handleFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthenticationException('The email address is not valid.');
      case 'user-disabled':
        return AuthenticationException('This user has been disabled.');
      case 'user-not-found':
        return AuthenticationException('No user found for that email.');
      case 'wrong-password':
        return AuthenticationException(
            'Wrong password provided for that user.');
      case 'email-already-in-use':
        return EmailAlreadyInUseException(
            'The email address is already in use by another account.');
      case 'operation-not-allowed':
        return AuthenticationException(
            'Operation not allowed. Please enable email sign-in in the Firebase Console.');
      case 'weak-password':
        return AuthenticationException('The password is too weak.');
      default:
        return ServerException(
            'An unexpected Firebase error occurred: ${e.message}');
    }
  }
}
