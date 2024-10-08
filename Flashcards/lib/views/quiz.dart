import 'package:flutter/material.dart';
import 'package:mp3/models/flash_card_collection.dart';
import 'package:mp3/models/flash_card_model.dart';
import 'package:mp3/utils/db_helper.dart';

class Quiz extends StatefulWidget {
  final int deckId;
  final String title;
  const Quiz(this.deckId, this.title, {Key? key}) : super(key: key);
  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  late Future<FlashCardCollection> flashCardCollection;
  late List<bool> isPeeked;
  int flashCardsCount = 0;
  int viewedCount = 0;
  int index = 0;
  int peekedCount = 0;
  int seenCardsCount = 0;
  late List<bool> isCardSeen;
  bool isAnswerPeeked = false;
  @override
  void initState() {
    super.initState();
    flashCardCollection = loadData();
  }

  Future<FlashCardCollection> loadData() async {
    String whereClause = "DeckListId= ${widget.deckId}";
    final flashCardData =
        await DBHelper().query("flashCardsList", where: whereClause);
    FlashCardCollection flashCollection = FlashCardCollection();
    if (flashCardData.isNotEmpty) {
      for (var flashData in flashCardData) {
        flashCollection.addInCollection(FlashCard(
            question: flashData['question'],
            answer: flashData['answer'],
            deckListId: flashData['DeckListId'],
            flashCardId: flashData['flashCardsListId']));
      }
      flashCollection.shuffle();
      flashCardsCount = flashCollection.length;
      isPeeked = List.filled(flashCollection.length, false);
      isCardSeen = List.filled(flashCollection.length, false);
    }
    return flashCollection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} Quiz',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<FlashCardCollection>(
        future: flashCardCollection,
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final flashCard = snapshot.data![index];

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      isAnswerPeeked
                          ? Card(
                              color: Colors.green[50],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  flashCard.answer,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Card(
                              color: Colors.blue[50],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  flashCard.question,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                index = (index == 0)
                                    ? flashCardsCount - 1
                                    : index - 1;
                                isAnswerPeeked = false;
                                if (!isCardSeen[index]) {
                                  isCardSeen[index] = true;
                                  seenCardsCount++;
                                }
                              });
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                          isAnswerPeeked
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isAnswerPeeked = false;
                                    });
                                  },
                                  icon: const Icon(Icons.visibility),
                                )
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isAnswerPeeked = true;
                                      if (!isPeeked[index]) {
                                        isPeeked[index] = true;
                                        peekedCount++;
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.visibility_off),
                                ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                index = (index + 1) % flashCardsCount;
                                isAnswerPeeked = false;
                                if (!isCardSeen[index]) {
                                  isCardSeen[index] = true;
                                  seenCardsCount++;
                                }
                              });
                            },
                            icon: const Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
                      Text("Seen $seenCardsCount of $flashCardsCount"),
                      Text("Peeked $peekedCount out of $seenCardsCount"),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
