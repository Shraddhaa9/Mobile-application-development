import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flash_card_collection.dart';
import 'package:mp3/models/flash_card_model.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String _databaseName = 'flashcard.db';
  static const int _databaseVersion = 1;

  DBHelper._();

  static final DBHelper _singleton = DBHelper._();

  factory DBHelper() => _singleton;

  Database? _database;

  get db async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();

    var dbPath = path.join(dbDir.path, _databaseName);

    //print(dbPath);

    //await deleteDatabase(dbPath);

    var db = await openDatabase(dbPath, version: _databaseVersion,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE deckList(
            deckListId INTEGER PRIMARY KEY,
            title TEXT
          )
        ''');

      await db.execute('''
          CREATE TABLE flashCardsList(
            flashCardsListId INTEGER PRIMARY KEY,
            question TEXT,
            answer TEXT,
            DeckListId INTEGER,
            FOREIGN KEY (DeckListId) REFERENCES DeckList(DeckListId)
          )
        ''');
    });

    return db;
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where}) async {
    final db = await this.db;
    return where == null ? db.query(table) : db.query(table, where: where);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> update(
      String table, Map<String, dynamic> data, String tableIDName) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: '$tableIDName = ?',
      whereArgs: [data[tableIDName]],
    );
  }

  Future<void> delete(String table, int id, String tableIDName) async {
    final db = await this.db;
    await db.delete(
      table,
      where: '$tableIDName = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertingInBatch(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    Batch batch = db.batch;
    batch.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveRecordsForJSONFile(
      List flashCardsData, String primaryTable, String secondaryTable) async {
    final db = await this.db;
    for (var element in flashCardsData) {
      Deck deck = Deck.fromJson(element);
      Map<String, dynamic> deckData = {'title': deck.title};
      int deckId = await db.insert(
        primaryTable,
        deckData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      FlashCardCollection? flashCards = deck.flashcards;
      List<FlashCard> flashList = flashCards!.getList();
      for (var flashCard in flashList) {
        Map<String, dynamic> flashCardData = {
          'question': flashCard.question,
          'answer': flashCard.answer,
          'DeckListId': deckId
        };
        await db.insert(
          secondaryTable,
          flashCardData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> queryForDeckData() async {
    final db = await this.db;
    return await db.rawQuery(
        'select d.deckListId,title,count(f.deckListId) as flashCardCount from deckList d left join flashcardslist f on d.deckListId=f.deckListId group by d.deckListId,title order by d.deckListId');
  }

  Future<void> deleteDeck(String primaryTable, String secondaryTable, int id,
      String tableIDName) async {
    final db = await this.db;
    await db.delete(
      primaryTable,
      where: '$tableIDName = ?',
      whereArgs: [id],
    );

    await db.delete(
      secondaryTable,
      where: '$tableIDName = ?',
      whereArgs: [id],
    );
  }
}
