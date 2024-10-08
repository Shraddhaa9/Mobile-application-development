import 'package:flutter/material.dart';
import 'package:mp3/models/deck_collection.dart';
import 'package:mp3/models/flash_card_model.dart';
import 'package:provider/provider.dart';

class FlashCardEdit extends StatefulWidget {
  final int deckId;
  final int flashCardId;

  const FlashCardEdit(this.deckId, this.flashCardId, {super.key});

  @override
  State<FlashCardEdit> createState() => _FlashCardEditState();
}

class _FlashCardEditState extends State<FlashCardEdit> {
  late FlashCard? _editedFlashCard;
  late DeckCollection? _collection;

  @override
  void initState() {
    super.initState();
    _collection = Provider.of<DeckCollection>(context, listen: false);

    if (widget.flashCardId != 0 && widget.deckId != 0) {
      _editedFlashCard = _collection!
          .getFlashCardDataForDeck(widget.deckId, widget.flashCardId);
    } else {
      _editedFlashCard = FlashCard(question: "", answer: "", deckListId: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    var deletedButton = widget.flashCardId == 0
        ? Container()
        : TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              await _collection?.deleteFlashCard(
                  widget.deckId, widget.flashCardId);

              Navigator.of(context).pop();
            },
          );

    return Scaffold(
        appBar: AppBar(title: const Text('Edit Card')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextFormField(
                    initialValue: _editedFlashCard?.question,
                    decoration: const InputDecoration(hintText: 'Question'),
                    onChanged: (value) => _editedFlashCard?.question = value,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextFormField(
                    initialValue: _editedFlashCard?.answer,
                    decoration: const InputDecoration(hintText: 'Answer'),
                    onChanged: (value) => _editedFlashCard?.answer = value,
                  ),
                ),
              ),
              Expanded(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: const Text('Save'),
                    onPressed: () async {
                      if (widget.flashCardId == 0) {
                        await _collection?.addNewFlashCard(
                            _editedFlashCard!, widget.deckId);
                      } else {
                        await _collection?.updateFlashCard(widget.flashCardId,
                            widget.deckId, _editedFlashCard);
                      }

                      Navigator.of(context).pop();
                    },
                  ),
                  deletedButton,
                ],
              ))
            ],
          ),
        ));
  }
}
