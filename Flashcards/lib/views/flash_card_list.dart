import 'package:flutter/material.dart';
import 'package:mp3/models/deck_collection.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flash_card_collection.dart';
import 'package:mp3/models/flash_card_model.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/flash_card_edit.dart';
import 'package:mp3/views/quiz.dart';
import 'package:provider/provider.dart';

class FlashCardList extends StatefulWidget {
  final int deckId;
  const FlashCardList(this.deckId, {super.key});
  @override
  State<FlashCardList> createState() => _FlashCardListState();
}

class _FlashCardListState extends State<FlashCardList> {
  late Deck deck;
  late DeckCollection _collection;
  bool isSorted = false;
  @override
  void initState() {
    super.initState();
    _collection = Provider.of<DeckCollection>(context, listen: false);

    deck = Deck.from(_collection.getDeckData(widget.deckId));
  }

  @override
  Widget build(BuildContext context) {
    final deckList = Provider.of<DeckCollection?>(context);
    final flashCardList = deckList?.getFlashCardData(widget.deckId);
    const snackBar = SnackBar(
      content: Text('No Flashcards available'),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(deck.title, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: isSorted
                  ? const Icon(Icons.access_time, color: Colors.white)
                  : const Icon(Icons.sort_by_alpha, color: Colors.white),
              onPressed: () async {
                List data = await reloadData();
                setState(() {
                  deckList?.clear();

                  for (var element in data) {
                    if (isSorted) {
                      deckList?.addInCollection(element);
                    } else {
                      deckList?.addInCollectionInSortOrder(element);
                    }
                  }
                  if (isSorted) {
                    isSorted = false;
                  } else {
                    isSorted = true;
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              onPressed: () {
                if (flashCardList != null) {
                  var deckId = widget.deckId;
                  var deckName = deck.title;
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ChangeNotifierProvider<DeckCollection?>.value(
                        value: deckList, child: Quiz(deckId, deckName));
                  }));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              var deckId = widget.deckId;

              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ChangeNotifierProvider<DeckCollection?>.value(
                    value: deckList, child: FlashCardEdit(deckId, 0));
              })).then((value) async {
                isSorted = false;
                List data = await reloadData();
                setState(() {
                  deckList?.clear();
                  for (var element in data) {
                    deckList?.addInCollection(element);
                  }
                });
              });
            },
            child: const Icon(Icons.add)),
        body: flashCardList != null
            ? Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width ~/ 200,
                          ),
                          itemCount: flashCardList.length,
                          itemBuilder: (context, index) {
                            final flashCard = flashCardList[index];
                            //crossAxisCount: 2,
                            return Card(
                                color: Colors.blue[100],
                                child: Container(
                                    alignment: Alignment.center,
                                    child: Stack(
                                      children: [
                                        InkWell(onTap: () {
                                          //print('Deck ${flashCard?.question} tapped');
                                          var deckId = widget.deckId;
                                          var flashCardId =
                                              flashCard.flashCardId;
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ChangeNotifierProvider<
                                                    DeckCollection?>.value(
                                                value: deckList,
                                                child: FlashCardEdit(
                                                    deckId, flashCardId!));
                                          })).then((value) async {
                                            List data = await reloadData();
                                            setState(() {
                                              deckList?.clear();
                                              for (var element in data) {
                                                deckList
                                                    ?.addInCollection(element);
                                              }
                                            });
                                          });
                                        }),
                                        Flex(
                                          direction: Axis.horizontal,
                                          children: [
                                            Flexible(
                                              child: Center(
                                                  child:
                                                      Text(flashCard.question)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )));
                          }))
                ],
              )
            : Container());
  }

  Future<List<Deck>> reloadData() async {
    final data = await DBHelper().queryForDeckData();

    List<Deck> deckList = List.empty(growable: true);
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
      deckList.add(Deck(
          deckId: finalData['deckListId'] as int,
          title: finalData['title'] as String,
          flashCardCount: finalData['flashCardCount'],
          flashcards: flashCardList));
    }

    return deckList;
  }
}
