import 'package:mp3/utils/db_helper.dart';

class FlashCard {
  int? flashCardId;
  String question;
  String answer;
  final int deckListId;

  FlashCard(
      {this.flashCardId,
      required this.question,
      required this.answer,
      required this.deckListId});

  FlashCard.from(FlashCard other)
      : question = other.question,
        answer = other.answer,
        deckListId = other.deckListId,
        flashCardId = other.flashCardId;

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
        question: json['question'] as String,
        answer: json['answer'] as String,
        deckListId: 0);
  }

  Future<void> saveFlashCards(FlashCard flashCard, Future<int> deckId) async {
    await DBHelper().insert("flashCardsList", {
      'question': flashCard.question,
      'answer': flashCard.answer,
      'DeckListId': deckId
    });
  }

  Future<int> saveNewFlashCards(FlashCard flashCard, int deckId) async {
    return await DBHelper().insert("flashCardsList", {
      'question': flashCard.question,
      'answer': flashCard.answer,
      'DeckListId': deckId
    });
  }

  Future<void> updateFlashCard(
      String question, String answer, int flashCardId, int deckId) async {
    await DBHelper().update(
        "flashcardslist",
        {
          'question': question,
          'answer': answer,
          'deckListId': deckId,
          'flashCardsListId': flashCardId
        },
        "flashCardsListId");
  }

  Future<void> deleteFlashCard(int flashCardId) async {
    await DBHelper().delete("flashCardsList", flashCardId, "flashCardsListId");
  }
}
