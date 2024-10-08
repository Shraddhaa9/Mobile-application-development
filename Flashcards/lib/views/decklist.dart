import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp3/models/deck_collection.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flash_card_collection.dart';
import 'package:mp3/models/flash_card_model.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/deck_edit_page.dart';
import 'package:mp3/views/flash_card_list.dart';
import 'package:provider/provider.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});
  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  @override
  Widget build(BuildContext context) {
    final deckList = Provider.of<DeckCollection?>(context);

    if (deckList == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Flashcard Decks",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () async {
                await readJsonFile();
                List data = await reloadData();
                setState(() {
                  deckList.clear();
                  for (var element in data) {
                    deckList.addInCollection(element);
                  }
                });
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ChangeNotifierProvider<DeckCollection>.value(
                    value: deckList, child: const DeckEditPage(0));
              })).then((value) async {
                List data = await reloadData();
                setState(() {
                  deckList.clear();
                  for (var element in data) {
                    deckList.addInCollection(element);
                  }
                });
              });
            },
            child: const Icon(Icons.add)),
        body: //Flex(
            //direction: Axis.horizontal,
            //children: [
            //Expanded(
            //child:
            GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 200,
                ),
                itemCount: deckList.length,
                itemBuilder: (context, index) {
                  final deck = deckList[index];
                  //crossAxisCount: 2,
                  return Card(
                      color: Colors.yellow[100],
                      child: Container(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              InkWell(onTap: () {
                                //print('Deck ${deck.title} tapped');
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return ChangeNotifierProvider<
                                          DeckCollection>.value(
                                      value: deckList,
                                      child: FlashCardList(deck.deckId!));
                                })).then((value) async {
                                  List data = await reloadData();
                                  setState(() {
                                    deckList.clear();
                                    for (var element in data) {
                                      deckList.addInCollection(element);
                                    }
                                  });
                                });
                              }),
                              Flex(
                                direction: Axis.horizontal,
                                children: [
                                  Flexible(
                                      child: Container(
                                    alignment: AlignmentDirectional.center,
                                    padding: const EdgeInsets.only(top: 50),
                                    child: Column(children: [
                                      Center(child: Text(deck.title)),
                                      Center(
                                          child: Text(
                                              '(${deck.flashCardCount} Cards)')),
                                    ]),
                                  )),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    var deckID = deckList[index].deckId;
                                    //print('Deck ${deckList[index].title} edited');
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return ChangeNotifierProvider<
                                              DeckCollection>.value(
                                          value: deckList,
                                          child: DeckEditPage(deckID!));
                                    })).then((value) async {
                                      List data = await reloadData();
                                      setState(() {
                                        deckList.clear();
                                        for (var element in data) {
                                          deckList.addInCollection(element);
                                        }
                                      });
                                    });
                                  },
                                ),
                              ),
                            ],
                          )));
                }));
    //],
    //));
  }

  Future<void> readJsonFile() async {
    final data = await rootBundle.loadString('assets/flashcards.json');
    List flashCardsData = json.decode(data);
    await DBHelper()
        .saveRecordsForJSONFile(flashCardsData, "DeckList", "flashCardsList");
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
