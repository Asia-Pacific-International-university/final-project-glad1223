// location_checkin_quest_adapter.dart
import 'package:final_project/domain/entities/quest.dart' as q;
import 'package:final_project/presentation/widgets/quest/location_checkin_quest_widget.dart';

class LocationCheckInQuestAdapter extends q.Quest {
  final q.Quest _quest;

  LocationCheckInQuestAdapter(this._quest)
      : super(
          id: _quest.id,
          type: _quest.type,
          title:
              _quest.title ?? '', // Provide a default non-null value for title
          description: _quest.description,
          locationName: _quest.locationName,
          latitude: _quest.latitude,
          longitude: _quest.longitude,
        );
}
