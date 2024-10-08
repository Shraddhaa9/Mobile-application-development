import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flash_card_collection.dart';
import 'package:mp3/models/flash_card_model.dart';

class DeckCollection with ChangeNotifier {
  final List<Deck> _deck;

  DeckCollection() : _deck = List.empty(growable: true);

  int get length => _deck.length;

  Deck operator [](int index) => _deck[index];

  Future<void> update(int deckId, Deck deck) async {
    Deck oldDeck = _deck.firstWhere((element) => element.deckId == deck.deckId);
    oldDeck.title = deck.title;
    deck.updateDeck(deck.title, deckId);
    notifyListeners();
  }

  void add(Deck deck) {
    _deck.add(deck);
    deck.saveDeck(deck.title);
    notifyListeners();
  }

  void addInCollection(Deck deck) {
    _deck.add(deck);

    notifyListeners();
  }

  void addInCollectionInSortOrder(Deck deck) {
    FlashCardCollection? flashCollection = deck.flashcards;
    if (flashCollection!.length > 0) {
      List<FlashCard> flashList = flashCollection.sortOrder();
      FlashCardCollection finalFlashCollection = FlashCardCollection();
      for (var element in flashList) {
        finalFlashCollection.addInCollection(element);
      }
      deck.flashcards = finalFlashCollection;
    }

    _deck.add(deck);

    notifyListeners();
  }

  void clear() {
    _deck.clear();
    notifyListeners();
  }

  Future<void> delete(int deckId) async {
    Deck deck = _deck.firstWhere((element) => element.deckId == deckId);

    deck.deleteDeck(deckId);
    notifyListeners();
  }

  Deck getDeckData(int deckID) {
    Deck deck = _deck.firstWhere((element) => element.deckId == deckID);
    return deck;
  }

  FlashCardCollection? getFlashCardData(int deckID) {
    Deck deck = _deck.firstWhere((element) => element.deckId == deckID);
    if (deck.flashCardCount == 0) {
      return null;
    } else {
      return deck.flashcards;
    }
  }

  FlashCard? getFlashCardDataForDeck(int deckId, int flashCardID) {
    Deck deck = _deck.firstWhere((element) => element.deckId == deckId);
    if (deck.flashcards != null) {
      FlashCard flashCard = deck.flashcards!.find(flashCardID);
      return flashCard;
    } else {
      return null;
    }
  }

  void addFlashCard(FlashCard flashCard) {
    flashCard.saveFlashCards(flashCard, flashCard.deckListId as Future<int>);
    notifyListeners();
  }

  Future<void> addNewFlashCard(FlashCard flashCard, int deckId) async {
    await flashCard.saveNewFlashCards(flashCard, deckId);
    notifyListeners();
  }

  Future<void> updateFlashCard(
      int flashCardId, int deckId, FlashCard? flashCard) async {
    flashCard?.updateFlashCard(
        flashCard.question, flashCard.answer, flashCardId, deckId);
    notifyListeners();
  }

  Future<void> deleteFlashCard(int deckId, int flashCardId) async {
    Deck deck = _deck.firstWhere((element) => element.deckId == deckId);
    FlashCard flashCard = deck.flashcards!.find(flashCardId);
    flashCard.deleteFlashCard(flashCardId);
    deck.flashcards?.removeWhere(flashCardId);
    notifyListeners();
  }
}
