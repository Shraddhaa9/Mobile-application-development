import 'package:flutter/material.dart';
import 'package:mp3/models/deck_collection.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flash_card_collection.dart';
import 'package:mp3/models/flash_card_model.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/decklist.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureProvider<DeckCollection?>(
        create: (_) => _loadData(), initialData: null, child: const DeckList());
  }

  Future<DeckCollection> _loadData() async {
    final data = await DBHelper().queryForDeckData();
    DeckCollection deckCollection = DeckCollection();
    for (var finalData in data) {
      String whereClause = "DeckListId= ${finalData['deckListId'] as int}";
      final flashCardData =
          await DBHelper().query("flashCardsList", where: whereClause);
      FlashCardCollection flashCardList = FlashCardCollection();
      if (flashCardData.isNotEmpty) {
        for (var flashData in flashCardData) {
          flashCardList.addInCollection(FlashCard(
              question: flashData['question'],
              answer: flashData['answer'],
              deckListId: flashData['DeckListId'],
              flashCardId: flashData['flashCardsListId']));
        }
      }
      deckCollection.addInCollection(Deck(
          deckId: finalData['deckListId'] as int,
          title: finalData['title'] as String,
          flashCardCount: finalData['flashCardCount'],
          flashcards: flashCardList));
    }
    return deckCollection;
  }
}
