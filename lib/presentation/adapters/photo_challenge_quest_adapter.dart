// photo_challenge_quest_adapter.dart
import 'package:final_project/domain/entities/quest.dart' as q;
import 'package:final_project/presentation/widgets/quest/photo_challenge_quest_widget.dart';

class PhotoChallengeQuestAdapter extends q.Quest {
  final q.Quest _quest;

  PhotoChallengeQuestAdapter(this._quest)
      : super(
          id: _quest.id,
          type: _quest.type,
          title:
              _quest.title ?? '', // Provide a default non-null value for title
          description: _quest.description,
          photoTheme: _quest.photoTheme,
        );
}
