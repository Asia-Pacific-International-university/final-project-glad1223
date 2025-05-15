// *** File: lib/presentation/screens/signup/signup_screen.dart ***

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/faculty_constants.dart'; // Import faculty list
import '../../providers/auth_provider.dart'; // Import auth provider
import '../../widgets/common/themed_button.dart';
import '../../widgets/common/loading_indicator.dart';

// Screen for new user registration.
class SignupScreen extends StatefulWidget {
  static const routeName = '/signup'; // Route name for navigation

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for validating the form
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedFaculty; // Holds the selected faculty

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Placeholder function to handle signup logic.
  void _signup(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text.trim() ==
          _confirmPasswordController.text.trim()) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider
            .signUp(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        )
            .then((_) {
          if (authProvider.user != null) {
            Navigator.pushReplacementNamed(context, '/faculty-selection');
          } else if (authProvider.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.errorMessage)),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        // Back button is automatically added by Navigator
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Join the Challenge!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Enter your username',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'you@university.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return const Center(child: LoadingIndicator());
                    }
                    return ThemedButton(
                      // Corrected to use text parameter
                      text: 'Sign Up',
                      onPressed: () => _signup(context),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Link back to Login
                TextButton(
                  onPressed: () {
                    // Pop the signup screen to go back to login
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    } else {
                      // Fallback if it cannot pop (e.g., deep linking)
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/login');
                    }
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
