import 'package:flutter/material.dart';
import 'completed_game_page.dart';

class NewGameCard extends StatefulWidget {
  final String id;
  final String player1;
  final String player2;
  final String status;
  final String turn;
  final String position;
  final String currentPlayer;

  NewGameCard({
    required this.id,
    required this.player1,
    required this.player2,
    required this.status,
    required this.turn,
    required this.position,
    required this.currentPlayer,
  });

  @override
  State<NewGameCard> createState() => _NewGameCardState();
}

class _NewGameCardState extends State<NewGameCard> {
  String ai = "";

  @override
  void initState() {
    super.initState();
    _checkAI();
  }

  void _checkAI() {
    if (["perfect", "random", "oneship"].contains(widget.player2)) {
      setState(() {
        ai = widget.player2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletedGamePage(
              id: widget.id,
              ai: ai,
              name: widget.currentPlayer,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Text(
            "#${widget.id}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            "${widget.player1} vs ${widget.player2}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: widget.status == "0"
                  ? const Text(
                      "matchMaking",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : widget.status == "1"
                      ? Text(
                          "${widget.player1} won",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : widget.status == "2"
                          ? Text(
                              "${widget.player2} won",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : widget.turn == widget.position
                              ? const Text(
                                  "myTurn",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : const Text(
                                  "OpponentTurn",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
            ),
          ),
        ],
      ),
    );
  }
}
