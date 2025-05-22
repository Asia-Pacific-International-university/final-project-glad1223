import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import '../../core/constants/app_constants.dart';
import 'package:final_project/presentation/providers/auth_provider.dart'; // Import Riverpod auth provider
import 'package:final_project/presentation/providers/leaderboard_provider.dart'; // Import Riverpod leaderboard provider
import '../widgets/common/loading_indicator.dart';
// import '../widgets/leaderboard/leaderboard_item.dart'; // Assuming you have this widget

class LeaderboardScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() =>
      _LeaderboardScreenState(); // Changed state type
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  // Changed state type
  @override
  void initState() {
    super.initState();
    // Use ref.read to access the notifier and call methods
    final authState = ref.read(authProvider);
    final leaderboardNotifier = ref.read(leaderboardProvider.notifier);

    if (authState.user?.role == UserRole.admin) {
      // Check isAdmin using authState
      leaderboardNotifier.fetchUserLeaderboard(); // Fetch all users for admin
    } else {
      leaderboardNotifier
          .fetchFacultyRankings(); // Fetch faculty rankings for regular users
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the necessary states from the providers
    final isAdmin = ref.watch(
        authProvider.select((state) => state.user?.role == UserRole.admin));
    final isLoading = ref.watch(leaderboardLoadingProvider);
    final errorMessage = ref.watch(leaderboardErrorMessageProvider);
    final userLeaderboardList = ref.watch(userLeaderboardListProvider);
    final facultyRankingList = ref.watch(facultyRankingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin User Monitoring' : 'Faculty Leaderboard'),
      ),
      body: isLoading
          ? const Center(child: LoadingIndicator())
          : errorMessage != null && errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : (isAdmin && userLeaderboardList.isEmpty) ||
                      (!isAdmin && facultyRankingList.isEmpty)
                  ? const Center(child: Text('No data on the leaderboard yet!'))
                  : ListView.builder(
                      itemCount: isAdmin
                          ? userLeaderboardList.length
                          : facultyRankingList.length,
                      itemBuilder: (context, index) {
                        if (isAdmin) {
                          final entry = userLeaderboardList[index];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(entry.userName),
                            subtitle:
                                Text('Faculty: ${entry.facultyName ?? 'N/A'}'),
                            trailing:
                                Text('${entry.totalPoints}'), // Use totalPoints
                          );
                        } else {
                          final ranking = facultyRankingList[index];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(ranking.facultyName),
                            trailing:
                                Text('${ranking.totalScore} Total Points'),
                          );
                        }
                      },
                    ),
    );
  }
}
