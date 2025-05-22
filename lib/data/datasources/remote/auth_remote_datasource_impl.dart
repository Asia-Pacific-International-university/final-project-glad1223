//import 'package:http/http.dart'
// as http; // Import if you still need it for other API calls
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:logger/logger.dart'; // Import the logger package
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart'; // Assuming this defines ServerException, AuthenticationException etc.
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';
import 'dart:async';

/// Implementation of [AuthRemoteDataSource] that interacts with Firebase Authentication and Firestore.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth; // Firebase Auth instance
  final FirebaseFirestore _firestore; // Firestore instance
  // Initialize a logger instance for this class
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1, // Show one method call for context
      errorMethodCount: 5, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print emojis
      printTime: false, // Should each log print a timestamp
    ),
  );

  /// Constructs an [AuthRemoteDataSourceImpl] with required Firebase dependencies.
  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String? facultyId,
    required UserRole role,
  }) async {
    _logger.d(
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
      _logger.i("User signed up successfully. Returning $newUser");
      return newUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      _logger.w(
        "Firebase Auth error during sign up",
      ); // Log the Firebase exception
      throw _handleFirebaseError(e);
    } catch (e) {
      // Handle other errors (e.g., Firestore errors)
      _logger.e(
        "Error during sign up: $e",
      ); // Log the generic error
      throw ServerException('Failed to sign up: ${e.toString()}'); // Corrected
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _logger.d("signInWithEmailAndPassword called for $email");
    try {
      // Attempt standard Firebase sign-in
      final firebaseUserCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = firebaseUserCredential.user;

      if (firebaseUser == null) {
        throw AuthenticationException('Failed to sign in.'); // Corrected
      }

      // Retrieve user data from Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // This case should ideally not happen if user signed in successfully via Firebase Auth
        // and was properly signed up. However, as a fallback for exemplary users,
        // we can try to create their Firestore document if it's missing.
        final exemplaryUser = ExemplaryUsers.findByEmail(email);
        if (exemplaryUser != null && exemplaryUser.password == password) {
          _logger.i(
              "Exemplary user $email signed in via Firebase Auth, but Firestore doc missing. Creating it now.");
          await _firestore.collection('users').doc(firebaseUser.uid).set({
            'username': exemplaryUser.username,
            'email': exemplaryUser.email,
            'role': exemplaryUser.role.name,
            'facultyId': exemplaryUser.facultyId,
            'totalPoints': 0,
            'badges': [],
          });
          // Re-fetch the document to ensure it's fresh
          final updatedUserDoc =
              await _firestore.collection('users').doc(firebaseUser.uid).get();
          return _userModelFromFirestoreDoc(firebaseUser, updatedUserDoc);
        } else {
          throw AuthenticationException(
              'User data not found in Firestore. This should not happen.'); // Corrected
        }
      }

      return _userModelFromFirestoreDoc(firebaseUser, userDoc);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      // If user-not-found or wrong-password for an exemplary user, attempt to sign them up.
      final exemplaryUser = ExemplaryUsers.findByEmail(email);
      if (exemplaryUser != null && exemplaryUser.password == password) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          _logger.i(
              "Attempting to auto-create exemplary user $email as they were not found or password was wrong.");
          try {
            // Auto-create the user in Firebase Auth
            final newFirebaseUserCredential =
                await _firebaseAuth.createUserWithEmailAndPassword(
              email: exemplaryUser.email,
              password: exemplaryUser.password,
            );
            final newFirebaseUser = newFirebaseUserCredential.user;

            if (newFirebaseUser == null) {
              throw AuthenticationException(
                  'Failed to auto-create exemplary user.'); // Corrected
            }

            // Create their Firestore document
            await _firestore.collection('users').doc(newFirebaseUser.uid).set({
              'username': exemplaryUser.username,
              'email': exemplaryUser.email,
              'role': exemplaryUser.role.name,
              'facultyId': exemplaryUser.facultyId,
              'totalPoints': 0,
              'badges': [],
            });

            // Return the newly created user model
            return UserModel(
              id: newFirebaseUser.uid,
              email: newFirebaseUser.email!,
              username: exemplaryUser.username,
              role: exemplaryUser.role,
              facultyId: exemplaryUser.facultyId,
              totalPoints: 0,
              badges: [],
            );
          } on firebase_auth.FirebaseAuthException catch (createError) {
            // If auto-creation fails (e.g., email-already-in-use by another user),
            // re-throw the original sign-in error.
            _logger.w(
                "Auto-creation failed for exemplary user: ${createError.code}",
                createError);
            throw _handleFirebaseError(e); // Re-throw original sign-in error
          }
        }
      }
      // For non-exemplary users or other Firebase errors, re-throw the original error
      _logger.w(
        "Firebase Auth error during sign in",
      );
      throw _handleFirebaseError(e);
    } catch (e) {
      // Handle other errors (e.g., network issues, data parsing)
      _logger.e(
        "Error during sign in: $e",
      );
      throw AuthenticationException(
          'Failed to sign in: ${e.toString()}'); // Corrected
    }
  }

  /// Helper method to convert Firebase User and Firestore DocumentSnapshot to UserModel.
  UserModel _userModelFromFirestoreDoc(
      firebase_auth.User firebaseUser, DocumentSnapshot userDoc) {
    if (!userDoc.exists || userDoc.data() == null) {
      throw AuthenticationException(
          'User data not found or is null in Firestore.'); // Corrected
    }
    final userData = userDoc.data() as Map<String, dynamic>;

    UserRole userRole;
    try {
      userRole = UserRole.values.firstWhere((e) =>
          e.name == userData['role']); // Convert role string back to enum
    } catch (e) {
      _logger.w(
          "Error parsing role: ${userData['role']}. Defaulting to User", e);
      userRole = UserRole.user; // Default role if the stored role is invalid
    }

    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      username: userData['username'] ?? '', // Provide a default value if null
      role: userRole,
      facultyId: userData['facultyId'],
      totalPoints: userData['totalPoints'],
      badges: List<String>.from(userData['badges'] ?? []),
    );
  }

  @override
  Future<void> signOut() async {
    _logger.d("signOut called");
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      _logger.e(
        "Error during sign out: $e",
      );
      throw ServerException('Failed to sign out: ${e.toString()}'); // Corrected
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    _logger.d("getCurrentUser called");
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    try {
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // This could happen if a user was deleted from Firestore but still logged in via Firebase Auth.
        // Or if it's an exemplary user whose Firestore doc was never created.
        final exemplaryUser = ExemplaryUsers.findByEmail(firebaseUser.email!);
        if (exemplaryUser != null) {
          _logger.i(
              "Exemplary user ${firebaseUser.email} found in Firebase Auth, but Firestore doc missing. Creating it now.");
          await _firestore.collection('users').doc(firebaseUser.uid).set({
            'username': exemplaryUser.username,
            'email': exemplaryUser.email,
            'role': exemplaryUser.role.name,
            'facultyId': exemplaryUser.facultyId,
            'totalPoints': 0,
            'badges': [],
          });
          // Re-fetch the document to ensure it's fresh
          final updatedUserDoc =
              await _firestore.collection('users').doc(firebaseUser.uid).get();
          return _userModelFromFirestoreDoc(firebaseUser, updatedUserDoc);
        }
        return null; // Or throw an exception if user should always exist
      }
      return _userModelFromFirestoreDoc(firebaseUser, userDoc);
    } catch (e) {
      _logger.e(
        "Error fetching current user: $e",
      );
      return null; // Or handle the error as needed.
    }
  }

  @override
  Future<UserModel> updateUserFaculty({
    required String userId,
    required String facultyId,
  }) async {
    _logger
        .d("updateUserFaculty called for $userId with facultyId: $facultyId");
    try {
      // 1. Update facultyId in Firestore
      await _firestore.collection('users').doc(userId).update({
        'facultyId': facultyId,
      });

      // 2. Retrieve the updated user data from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null || firebaseUser.uid != userId) {
        throw AuthenticationException(
            'Current Firebase user mismatch or not logged in.'); // Corrected
      }

      return _userModelFromFirestoreDoc(firebaseUser, userDoc);
    } catch (e) {
      _logger.e(
        "Error updating user faculty: $e",
      );
      throw ServerException(
          'Failed to update faculty: ${e.toString()}'); // Corrected
    }
  }

  // Helper function to handle Firebase Auth errors
  Exception _handleFirebaseError(firebase_auth.FirebaseAuthException e) {
    _logger.e(
      "Firebase Auth Exception: ${e.code} - ${e.message}",
    ); // Log the specific Firebase error
    switch (e.code) {
      case 'invalid-email':
        return AuthenticationException(
            'The email address is not valid.'); // Corrected
      case 'user-disabled':
        return AuthenticationException(
            'This user has been disabled.'); // Corrected
      case 'user-not-found':
        return AuthenticationException(
            'No user found for that email.'); // Corrected
      case 'wrong-password':
        return AuthenticationException(
            'Wrong password provided for that user.'); // Corrected
      case 'email-already-in-use':
        return EmailAlreadyInUseException(
            'The email address is already in use by another account.'); // Corrected
      case 'operation-not-allowed':
        return AuthenticationException(
            'Operation not allowed. Please enable email sign-in in the Firebase Console.'); // Corrected
      case 'weak-password':
        return AuthenticationException(
            'The password is too weak.'); // Corrected
      default:
        return ServerException(
            'An unexpected Firebase error occurred: ${e.message}'); // Corrected
    }
  }
}
