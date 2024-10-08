import 'package:flutter/material.dart';
import 'package:mp3/models/deck_collection.dart';
import 'package:mp3/models/deck.dart';
import 'package:provider/provider.dart';

class DeckEditPage extends StatefulWidget {
  final int deckId;

  const DeckEditPage(this.deckId, {super.key});

  @override
  State<DeckEditPage> createState() => _DeckEditPageState();
}

class _DeckEditPageState extends State<DeckEditPage> {
  late Deck _editedDeck;
  late DeckCollection _collection;

  @override
  void initState() {
    super.initState();
    _collection = Provider.of<DeckCollection>(context, listen: false);

    if (widget.deckId != 0) {
      _editedDeck = Deck.from(_collection.getDeckData(widget.deckId));
    } else {
      _editedDeck = Deck(title: "");
    }
  }

  @override
  Widget build(BuildContext context) {
    var deletedButton = widget.deckId == 0
        ? Container()
        : TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              await _collection.delete(widget.deckId);

              Navigator.of(context).pop();
            },
          );

    return Scaffold(
        appBar: AppBar(title: const Text('Edit Deck')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextFormField(
                  initialValue: _editedDeck.title,
                  decoration: const InputDecoration(hintText: 'Deck Name'),
                  onChanged: (value) => _editedDeck.title = value,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (widget.deckId == 0) {
                        _collection.add(_editedDeck);
                      } else {
                        _collection.update(widget.deckId, _editedDeck);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  deletedButton,
                ],
              )
            ],
          ),
        ));
  }
}
