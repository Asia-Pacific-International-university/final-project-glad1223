import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/faculty_constants.dart'; // Assuming this file exists
import '../../providers/auth_provider.dart'; // To handle the selection
import '../../widgets/common/themed_button.dart'; // Assuming this exists

class FacultySelectionScreen extends StatelessWidget {
  const FacultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Faculty')),
      body: Consumer<AuthProvider>(
        // Assuming AuthProvider handles faculty selection
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Choose your faculty to personalize your experience:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: FacultyConstants
                        .faculties.length, // Assuming a list of faculties here
                    itemBuilder: (context, index) {
                      final faculty = FacultyConstants.faculties[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(faculty),
                          onTap: () {
                            authProvider.selectFaculty(
                                faculty); // Method in AuthProvider
                            // You might navigate to the next screen here, e.g., home
                            Navigator.of(context).pushReplacementNamed(
                                '/home'); // Using a route name
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ThemedButton(
                  // Using a custom themed button
                  onPressed: authProvider.selectedFaculty != null
                      ? () {
                          // You might have already navigated in the ListTile's onTap
                          // Or handle navigation here if not done in ListTile
                          if (authProvider.selectedFaculty != null) {
                            Navigator.of(context).pushReplacementNamed('/home');
                          } else {
                            // Optionally show a message to select a faculty
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please select a faculty.')),
                            );
                          }
                        }
                      : null, // Disable button if no faculty is selected
                  label: 'Continue',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
