import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/presentation/providers/profile_provider.dart'; // Path to your provider
import 'package:final_project/presentation/widgets/common/loading_indicator.dart'; // Assuming this exists
import 'package:final_project/domain/entities/user.dart'; // Import the User class

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(
                child: LoadingIndicator()); // Using your loading indicator
          } else if (profileProvider.errorMessage.isNotEmpty) {
            return Center(
                child: Text('Error: ${profileProvider.errorMessage}'));
          } else if (profileProvider.user == null) {
            return const Center(
                child: Text('Could not load profile information.'));
          } else {
            final User user =
                profileProvider.user!; // Non-null assertion since we checked

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 60,
                      // You'll likely load the user's avatar here based on user data
                      child: Icon(Icons.person, size: 60),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Username:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(user.username, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  const Text('Email:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(user.email, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  const Text('Faculty:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(user.faculty ?? 'N/A', // Use null-aware operator here
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  const Text('Score:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(user.totalPoints.toString(),
                      style: const TextStyle(
                          fontSize:
                              18)), // Access score directly and convert to String
                  // Add more profile information as needed
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
