// *** File: lib/presentation/screens/login/login_screen.dart ***

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/themed_button.dart';
import '../../widgets/common/loading_indicator.dart';

// Screen for user login.
class LoginScreen extends StatefulWidget {
  static const routeName = '/login'; // Route name for navigation

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for validating the form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider
          .signIn(_emailController.text.trim(), _passwordController.text.trim())
          .then((_) {
        if (authProvider.user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (authProvider.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pulse Login'),
        automaticallyImplyLeading: false, // Remove back button on login screen
      ),
      body: Center(
        child: SingleChildScrollView(
          // Allows scrolling on smaller screens
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Make elements stretch
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // App Logo Placeholder
                const Icon(
                  // Removed the non-existent icon and used a standard one.
                  Icons.school, // Using a more generic icon.
                  size: 80,
                  color: Colors.blue, // You can change the color as needed.
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

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
                  obscureText: true, // Hide password
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    // Add more password validation if needed (e.g., length)
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Error Message Display (Handled by SnackBar now)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return const Center(
                        child: LoadingIndicator(),
                      );
                    }
                    return ThemedButton(
                      // Corrected to use the text parameter.
                      text: 'Login',
                      onPressed: () => _login(context),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Link to Signup Screen
                TextButton(
                  onPressed: () {
                    // Navigate to Signup Screen
                    Navigator.of(context).pushNamed('/signup');
                  },
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
