// In this screen, Admins can see *all* users' scores, while regular users see faculty ranking.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Or riverpod
import '../../core/constants/app_constants.dart'; // Import role enum
import '../providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart'; // Path to your provider
import '../widgets/common/loading_indicator.dart'; // Assuming this exists
// import '../widgets/leaderboard/leaderboard_item.dart'; // Assuming you have this widget

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin
            ? 'Admin User Monitoring'
            : 'Faculty Leaderboard'), // Dynamic title
      ),
      body: Consumer<LeaderboardProvider>(
        builder: (context, leaderboardProvider, child) {
          if (leaderboardProvider.isLoading) {
            return const Center(
                child: LoadingIndicator()); // Using your loading indicator
          } else if (leaderboardProvider.errorMessage.isNotEmpty) {
            return Center(
                child: Text('Error: ${leaderboardProvider.errorMessage}'));
          } else if (leaderboardProvider.leaderboardList.isEmpty) {
            return const Center(child: Text('No data on the leaderboard yet!'));
          } else {
            return ListView.builder(
              itemCount: leaderboardProvider.leaderboardList.length,
              itemBuilder: (context, index) {
                final entry = leaderboardProvider.leaderboardList[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(entry.userName ??
                      'Unknown User'), // Assuming 'userName' property
                  subtitle: isAdmin
                      ? Text('Faculty: ${entry.facultyName ?? 'N/A'}')
                      : null, // Show faculty only for admin view
                  trailing:
                      Text('${entry.score ?? 0}'), // Assuming 'score' property
                );
              },
            );
          }
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:final_project/presentation/providers/leaderboard_provider.dart'; // Path to your provider
// import 'package:final_project/presentation/widgets/common/loading_indicator.dart'; // Assuming this exists

// class LeaderboardScreen extends StatelessWidget {
//   const LeaderboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Leaderboard')),
//       body: Consumer<LeaderboardProvider>(
//         builder: (context, leaderboardProvider, child) {
//           if (leaderboardProvider.isLoading) {
//             return const Center(
//                 child: LoadingIndicator()); // Using your loading indicator
//           } else if (leaderboardProvider.errorMessage.isNotEmpty) {
//             return Center(
//                 child: Text('Error: ${leaderboardProvider.errorMessage}'));
//           } else if (leaderboardProvider.leaderboardList.isEmpty) {
//             return const Center(
//                 child: Text('No players on the leaderboard yet!'));
//           } else {
//             return ListView.builder(
//               itemCount: leaderboardProvider.leaderboardList.length,
//               itemBuilder: (context, index) {
//                 final entry = leaderboardProvider.leaderboardList[index];
//                 return ListTile(
//                   leading: CircleAvatar(child: Text('${index + 1}')),
//                   title: Text(entry.userName ??
//                       'Unknown User'), // Assuming 'userName' property
//                   trailing:
//                       Text('${entry.score ?? 0}'), // Assuming 'score' property
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
