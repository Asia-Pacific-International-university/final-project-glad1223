import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import 'package:go_router/go_router.dart';
import 'package:final_project/presentation/providers/auth_provider.dart'; // Import Riverpod auth provider
import 'package:final_project/presentation/widgets/auth/auth_text_field.dart';
import 'package:final_project/presentation/widgets/common/loading_indicator.dart';
import 'package:final_project/core/constants/app_constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState(); // Changed state type
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Changed state type
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Access the AuthNotifier to call methods
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Watch the state for navigation after the async operation completes
      // The state is now updated by the notifier, so we can react to it.
      final authState =
          ref.read(authProvider); // Read current state after submission attempt

      if (authState.user != null) {
        GoRouter.of(context).go(AppConstants.homeRoute);
      } else if (authState.errorMessage != null &&
          authState.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the loading and error state from the authProvider
    final isLoading =
        ref.watch(authProvider.select((state) => state.isLoading));
    final errorMessage =
        ref.watch(authProvider.select((state) => state.errorMessage));

    // Optional: Listen for error messages and show SnackBar immediately
    ref.listen<String?>(authErrorMessageProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Use the isLoading provider directly
                if (isLoading)
                  const LoadingIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).go(AppConstants.signUpRoute);
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
