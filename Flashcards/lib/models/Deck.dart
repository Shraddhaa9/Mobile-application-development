import 'package:flutter/material.dart';
import 'package:mp3/models/flash_card_collection.dart';
import 'package:mp3/utils/db_helper.dart';
import 'flash_card_model.dart';

class Deck with ChangeNotifier {
  int? deckId;
  String title;
  int? flashCardCount;
  FlashCardCollection? flashcards;
  Deck(
      {this.deckId, required this.title, this.flashCardCount, this.flashcards});

  factory Deck.fromJson(Map<String, dynamic> data) {
    String deckTitle = data['title'];
    List flashcardsList = data['flashcards'];
    FlashCardCollection flashCardList = FlashCardCollection();
    for (var flashCard in flashcardsList) {
      FlashCard tmpFlashCard = FlashCard.fromJson(flashCard);
      flashCardList.addInCollection(tmpFlashCard);
    }

    return Deck(
        deckId: 1,
        title: deckTitle,
        flashCardCount: flashcardsList.length,
        flashcards: flashCardList);
  }

  Future<int> saveDeck(String titleName) async {
    int deckID = await DBHelper().insert("deckList", {'title': title});
    return deckID;
  }

  Deck.from(Deck other)
      : deckId = other.deckId,
        title = other.title;

  Future<void> updateDeck(String titleName, int deckId) async {
    await DBHelper().update(
        "deckList", {'title': title, 'deckListId': deckId}, "deckListId");
  }

  Future<void> deleteDeck(int deckId) async {
    await DBHelper()
        .deleteDeck("deckList", "flashCardsList", deckId, "deckListId");
  }
}
