// *** File: lib/presentation/screens/auth/signup_screen.dart ***

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Or flutter_riverpod if you use that
import '../../../domain/entities/user.dart'; // Import User entity
import '../../providers/auth_provider.dart'; // Import AuthProvider
// import '../../providers/faculty_provider.dart'; // Assuming you have a provider for faculties
import '../../../core/constants/app_constants.dart'; // Import UserRole enum and extension
import '../../widgets/common/themed_button.dart';
import '../../widgets/common/loading_indicator.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup'; // Route name for navigation

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  UserRole _selectedRole = UserRole.user; // Default role is User

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      // Dismiss the keyboard
      FocusScope.of(context).unfocus();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Call signUp without facultyId in this screen
      final signedUpUser = await authProvider.signUp(
        email: _emailController.text.trim(), // Trim whitespace
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
        role: _selectedRole, // Pass the selected role
      );

      // Check if sign-up was successful
      if (signedUpUser != null) {
        print('User signed up successfully: ${signedUpUser.username}');
        // Check if user needs to select faculty and navigate accordingly
        if (authProvider.requiresFacultySelection()) {
          print('Navigating to Faculty Selection Screen...');
          // Navigate to Faculty Selection Screen
          Navigator.of(context).pushReplacementNamed(
              '/auth/faculty_selection'); // Use your AppRouter route name
        } else {
          // Navigate to Home (e.g., Admin user or users from simulation with faculty)
          print('Navigating to Home Screen...');
          Navigator.of(context)
              .pushReplacementNamed('/home'); // Use your AppRouter route name
        }
      } else if (authProvider.errorMessage != null &&
          authProvider.errorMessage!.isNotEmpty) {
        // Show error message from provider
        print('Signup failed: ${authProvider.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(authProvider.errorMessage ??
                  'An unknown error occurred during signup')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        // Center the content vertically if it fits
        child: SingleChildScrollView(
          // Allow scrolling if content overflows
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              // Use Column instead of ListView if you want fixed height or centered content
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center column content
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch children horizontally
              children: [
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Email Field (Consider using your AuthTextField widget)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email format validation
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field (Consider using your AuthTextField widget)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      // Example minimum length
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username Field (Consider using your AuthTextField widget)
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    // Add username specific validation if needed
                    return null;
                  },
                ),
                const SizedBox(height: 24), // Increased spacing

                // Role Selection
                const Text('Select Role:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<UserRole>(
                        title: const Text('User'),
                        value: UserRole.user,
                        groupValue: _selectedRole,
                        onChanged: (UserRole? value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      ),
                    ),
                    // IMPORTANT: This allows users to sign up as Admin.
                    // In a real app, remove or protect this option heavily!
                    Expanded(
                      child: RadioListTile<UserRole>(
                        title: const Text('Admin'),
                        value: UserRole.admin,
                        groupValue: _selectedRole,
                        onChanged: (UserRole? value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Increased spacing

                // Sign Up Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ThemedButton(
                      text: 'Sign Up',
                      onPressed: authProvider.isLoading ? null : _signUp,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Link to Login Screen
                TextButton(
                  onPressed: () {
                    // Use your AppRouter for navigation
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// // *** File: lib/presentation/screens/signup/signup_screen.dart ***

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/constants/faculty_constants.dart'; // Import faculty list
// import '../../providers/auth_provider.dart'; // Import auth provider
// import '../../widgets/common/themed_button.dart';
// import '../../widgets/common/loading_indicator.dart';

// // Screen for new user registration.
// class SignupScreen extends StatefulWidget {
//   static const routeName = '/signup'; // Route name for navigation

//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>(); // Key for validating the form
//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   String? _selectedFaculty; // Holds the selected faculty

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   // Placeholder function to handle signup logic.
//   void _signup(BuildContext context) {
//     if (_formKey.currentState!.validate()) {
//       if (_passwordController.text.trim() ==
//           _confirmPasswordController.text.trim()) {
//         final authProvider = Provider.of<AuthProvider>(context, listen: false);
//         authProvider
//             .signUp(
//           _usernameController.text.trim(),
//           _emailController.text.trim(),
//           _passwordController.text.trim(),
//         )
//             .then((_) {
//           if (authProvider.user != null) {
//             Navigator.pushReplacementNamed(context, '/faculty-selection');
//           } else if (authProvider.errorMessage.isNotEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(authProvider.errorMessage)),
//             );
//           }
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Passwords do not match.')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Account'),
//         // Back button is automatically added by Navigator
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 Text(
//                   'Join the Challenge!',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),

//                 // Username Field
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Username',
//                     prefixIcon: Icon(Icons.person),
//                     hintText: 'Enter your username',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a username';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Email Field
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: Icon(Icons.email),
//                     hintText: 'you@university.com',
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null ||
//                         value.isEmpty ||
//                         !value.contains('@')) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Password Field
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: Icon(Icons.lock),
//                   ),
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty || value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Confirm Password Field
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   decoration: const InputDecoration(
//                     labelText: 'Confirm Password',
//                     prefixIcon: Icon(Icons.lock_outline),
//                   ),
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please confirm your password';
//                     }
//                     if (value != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),

//                 Consumer<AuthProvider>(
//                   builder: (context, authProvider, child) {
//                     if (authProvider.isLoading) {
//                       return const Center(child: LoadingIndicator());
//                     }
//                     return ThemedButton(
//                       // Corrected to use text parameter
//                       text: 'Sign Up',
//                       onPressed: () => _signup(context),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Link back to Login
//                 TextButton(
//                   onPressed: () {
//                     // Pop the signup screen to go back to login
//                     if (Navigator.canPop(context)) {
//                       Navigator.of(context).pop();
//                     } else {
//                       // Fallback if it cannot pop (e.g., deep linking)
//                       Navigator.of(
//                         context,
//                       ).pushReplacementNamed('/login');
//                     }
//                   },
//                   child: const Text('Already have an account? Login'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
