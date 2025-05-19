// lib/presentation/screens/auth/faculty_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart'; // Import constants for faculty list
import '../../providers/auth_provider.dart'; // Import AuthProvider
import '../../widgets/common/themed_button.dart'; // Assuming this exists

class FacultySelectionScreen extends StatefulWidget {
  const FacultySelectionScreen({Key? key}) : super(key: key);

  @override
  _FacultySelectionScreenState createState() => _FacultySelectionScreenState();
}

class _FacultySelectionScreenState extends State<FacultySelectionScreen> {
  String? _selectedFacultyId;
  // Use the faculty list from AppFaculties constants
  final List<MapEntry<String, String>> _facultyList =
      AppFaculties.facultyList; // Use the static getter

  @override
  void initState() {
    super.initState();
    // Add a post-frame callback to check redirection logic immediately after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRedirect();
    });
  }

  void _checkRedirect() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // If user is not logged in OR doesn't need faculty selection, redirect away
    if (authProvider.currentUser == null ||
        !authProvider.requiresFacultySelection()) {
      print(
          'FacultySelectionScreen: Redirecting. User null: ${authProvider.currentUser == null}, Needs selection: ${authProvider.requiresFacultySelection()}');
      // Redirect to home or login - Home is likely correct if they somehow got here when they shouldn't have
      Navigator.of(context)
          .pushReplacementNamed('/home'); // Use your AppRouter route
    } else {
      print('FacultySelectionScreen: User needs faculty selection.');
    }
  }

  void _selectFaculty() async {
    // Validate that a faculty is selected
    if (_selectedFacultyId == null || _selectedFacultyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your faculty')),
      );
      return;
    }

    // Get the AuthProvider and current user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    // Double check user is still logged in and needs faculty
    if (currentUser == null || !authProvider.requiresFacultySelection()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: User session invalid or faculty already set.')),
      );
      Navigator.of(context)
          .pushReplacementNamed('/login'); // Go back to login/splash
      return;
    }

    // Call the AuthProvider method to update the user's faculty
    final success = await authProvider.updateUserFaculty(
      userId: currentUser.id,
      facultyId: _selectedFacultyId!,
    );

    // Check the result of the update operation
    if (success) {
      print('Faculty updated successfully!');
      // Navigate to the Home Screen upon success
      Navigator.of(context)
          .pushReplacementNamed('/home'); // Use your AppRouter route
    } else {
      // Show error message if update failed
      print('Faculty update failed: ${authProvider.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(authProvider.errorMessage ?? 'Failed to update faculty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer or check authProvider.isLoading for the button
    final authProvider = Provider.of<AuthProvider>(context);

    // Show a loading/empty screen briefly while _checkRedirect runs
    // Also prevent building the main UI if the user shouldn't be here
    if (authProvider.currentUser == null ||
        !authProvider.requiresFacultySelection()) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Faculty')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            // Add SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome! Please select your faculty to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Select Faculty'),
                  value: _selectedFacultyId,
                  items: _facultyList.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key, // Use ID as value
                      child: Text(entry.value), // Display Name
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFacultyId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your faculty';
                    }
                    return null;
                  },
                  hint: const Text('Choose a Faculty'),
                ),
                const SizedBox(height: 24),
                // Use a Consumer for the button to react to the provider's loading state
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ThemedButton(
                      text: 'Confirm Faculty',
                      onPressed: authProvider.isLoading ? null : _selectFaculty,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
