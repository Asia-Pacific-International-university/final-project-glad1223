import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import 'package:final_project/presentation/providers/profile_provider.dart'; // Import Riverpod profile provider
import 'package:final_project/presentation/widgets/common/loading_indicator.dart';
import 'package:final_project/domain/entities/user.dart';
import 'package:final_project/presentation/providers/auth_provider.dart'; // Import Riverpod auth provider

class ProfileScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState(); // Changed state type
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Changed state type
  @override
  void initState() {
    super.initState();
    // Get the userId from the AuthProvider (now a Riverpod provider)
    final userId = ref.read(authProvider).user?.id;

    if (userId != null) {
      // Call the notifier to fetch the user profile
      ref.read(profileProvider.notifier).getUserProfile(userId);
    } else {
      print('Error: User ID not available on ProfileScreen');
      // You might want to navigate back to the login screen or show an error.
      // GoRouter.of(context).go(AppConstants.loginRoute); // Example navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the profile state from the provider
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: profileState.isLoading
          ? const Center(child: LoadingIndicator())
          : profileState.errorMessage != null &&
                  profileState.errorMessage!.isNotEmpty
              ? Center(child: Text('Error: ${profileState.errorMessage!}'))
              : profileState.user == null
                  ? const Center(
                      child: Text('Could not load profile information.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: CircleAvatar(
                              radius: 60,
                              child: Icon(Icons.person, size: 60),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Username:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(profileState.user!.username,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 12),
                          const Text('Email:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(profileState.user!.email,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 12),
                          const Text('Faculty:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(profileState.user!.facultyName ?? 'N/A',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 12),
                          const Text('Score:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(profileState.user!.totalPoints.toString(),
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 12),
                          const Text('Badges:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          profileState.user!.badges.isNotEmpty
                              ? Wrap(
                                  spacing: 8.0,
                                  children: profileState.user!.badges
                                      .map((badge) => Chip(label: Text(badge)))
                                      .toList(),
                                )
                              : const Text('No badges earned yet.'),
                        ],
                      ),
                    ),
    );
  }
}
