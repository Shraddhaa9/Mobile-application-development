import 'package:flutter/material.dart';
import 'game_card.dart';
import 'new_gamecard.dart';

class FinishedList extends StatefulWidget {
  final List<GameCard> completedGames;
  final String currentPlayer;

  FinishedList({required this.completedGames, required this.currentPlayer});

  @override
  State<FinishedList> createState() => _FinishedListState();
}

class _FinishedListState extends State<FinishedList> {
  late List<GameCard> games;

  @override
  void initState() {
    super.initState();
    games = widget.completedGames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completed Games")),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: ListTile(
              title: NewGameCard(
                id: games[index].id,
                player1: games[index].player1,
                player2: games[index].player2,
                status: games[index].status,
                turn: games[index].turn,
                position: games[index].position,
                currentPlayer: widget.currentPlayer,
              ),
            ),
          );
        },
      ),
    );
  }
}
