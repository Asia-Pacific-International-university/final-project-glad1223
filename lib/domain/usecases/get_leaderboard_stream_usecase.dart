import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/entities/leaderboard_entry.dart';
import 'package:final_project/domain/repositories/leaderboard_repository.dart';

class GetLeaderboardStreamUseCase
    implements NoParamStreamUseCase<List<LeaderboardEntry>> {
  final LeaderboardRepository _leaderboardRepository;

  GetLeaderboardStreamUseCase({required this.leaderboardRepository});

  @override
  Stream<List<LeaderboardEntry>> execute() {
    return _leaderboardRepository.getLeaderboardStream();
  }
}
