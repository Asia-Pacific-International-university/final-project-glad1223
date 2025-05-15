// lib/presentation/providers/quest_provider.dart
import 'package:flutter/material.dart';
import '../../domain/usecases/get_active_quest_usecase.dart';
import '../../domain/entities/quest.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart'; // Import dartz

class QuestProvider extends ChangeNotifier {
  final GetActiveQuestUseCase _getActiveQuestUseCase;

  QuestProvider({required GetActiveQuestUseCase getActiveQuestUseCase})
      : _getActiveQuestUseCase = getActiveQuestUseCase;

  Quest? _activeQuest;
  Quest? get activeQuest => _activeQuest;

  Failure? _failure;
  Failure? get failure => _failure;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getActiveQuest() async {
    _isLoading = true;
    notifyListeners();
    final result = await _getActiveQuestUseCase(); // Call the use case
    result.fold(
      (failure) {
        // Handle failure
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (quest) {
        // Handle success
        _activeQuest = quest;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
