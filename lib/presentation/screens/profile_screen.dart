import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/presentation/providers/profile_provider.dart';
import 'package:final_project/presentation/widgets/common/loading_indicator.dart';
import 'package:final_project/domain/entities/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // You'll likely need the userId here. How are you accessing it?
    // For example, if it's passed as an argument to the screen:
    // final userId = ModalRoute.of(context)!.settings.arguments as String;
    // Or if it's stored in your AuthProvider:
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final userId = authProvider.userId; // Assuming you have this

    // Replace 'someUserId' with how you get the actual user ID
    Provider.of<ProfileProvider>(context, listen: false)
        .getUserProfile('someUserId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          } else if (profileProvider.errorMessage.isNotEmpty) {
            return Center(
                child: Text('Error: ${profileProvider.errorMessage}'));
          } else if (profileProvider.user == null) {
            return const Center(
                child: Text('Could not load profile information.'));
          } else {
            final User user = profileProvider.user!;

            return Padding(
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
                  Text(user.faculty ?? 'N/A',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  const Text('Score:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(user.totalPoints.toString(),
                      style: const TextStyle(fontSize: 18)),
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
