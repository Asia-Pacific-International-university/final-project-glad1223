import 'package:flutter/material.dart';
import 'package:final_project/domain/entities/leaderboard_entry.dart';

class LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const LeaderboardItem({super.key, required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('$rank'),
      title: Text(entry.userName ?? 'N/A'), // Use userName, handle null with ??
      trailing: Text('${entry.score ?? 0} Points'), // Use score, null with ??
    );
  }
}
