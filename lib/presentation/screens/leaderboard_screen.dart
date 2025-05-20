// In this screen, Admins can see *all* users' scores, while regular users see faculty ranking.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Or riverpod
import '../../core/constants/app_constants.dart'; // Import role enum
import '../providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart'; // Path to your provider
import '../widgets/common/loading_indicator.dart'; // Assuming this exists
// import '../widgets/leaderboard/leaderboard_item.dart'; // Assuming you have this widget

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);

    if (authProvider.isAdmin()) {
      leaderboardProvider.fetchUserLeaderboard(); // Fetch all users for admin
    } else {
      leaderboardProvider
          .fetchFacultyRankings(); // Fetch faculty rankings for regular users
    }
  }

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
          } else if ((isAdmin &&
                  leaderboardProvider.userLeaderboardList.isEmpty) ||
              (!isAdmin && leaderboardProvider.facultyRankingList.isEmpty)) {
            return const Center(child: Text('No data on the leaderboard yet!'));
          } else {
            return ListView.builder(
              itemCount: isAdmin
                  ? leaderboardProvider.userLeaderboardList.length
                  : leaderboardProvider.facultyRankingList.length,
              itemBuilder: (context, index) {
                if (isAdmin) {
                  final entry = leaderboardProvider.userLeaderboardList[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(entry.userName ?? 'Unknown User'),
                    subtitle: Text('Faculty: ${entry.facultyName ?? 'N/A'}'),
                    trailing: Text('${entry.score ?? 0}'),
                  );
                } else {
                  final ranking = leaderboardProvider.facultyRankingList[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(ranking.facultyName),
                    trailing: Text('${ranking.totalScore} Total Points'),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
