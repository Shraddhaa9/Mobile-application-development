import 'package:flutter/material.dart';
import 'package:mp3/models/flash_card_model.dart';

class FlashCardCollection extends ChangeNotifier {
  final List<FlashCard> _flashCard;

  FlashCardCollection() : _flashCard = List.empty(growable: true);

  int get length => _flashCard.length;

  FlashCard operator [](int index) => _flashCard[index];
  void addInCollection(FlashCard flashCard) {
    _flashCard.add(flashCard);

    notifyListeners();
  }

  FlashCard find(int flashCardID) {
    return _flashCard
        .firstWhere((element) => element.flashCardId == flashCardID);
  }

  void removeWhere(int flashCardID) {
    _flashCard.removeWhere((element) => element.flashCardId == flashCardID);
  }

  void clear() {
    _flashCard.clear();
    notifyListeners();
  }

  List<FlashCard> getList() => _flashCard;
  List<FlashCard> sortOrder() {
    _flashCard.sort((flashCardFirst, flashCardSecond) =>
        flashCardFirst.question.compareTo(flashCardSecond.question));

    return _flashCard;
  }

  List<FlashCard> shuffle() {
    _flashCard.shuffle();
    return _flashCard;
  }
}
