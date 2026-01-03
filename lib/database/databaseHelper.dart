import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dopamine_menu/models/dopMenu.dart';
import 'package:dopamine_menu/models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dopamine.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<List<DopMenu>> readAllItems() async {
    final db = await instance.database;
    final result = await db.query('dop_menu');
    return result.map((json) => DopMenu.fromMap(json)).toList();
  }

  Future<int> create(DopMenu item) async {
    final db = await instance.database;
    return await db.insert('dop_menu', item.toMap());
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dop_menu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        image TEXT,
        points INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        avatar TEXT,
        totalPoints INTEGER,
        favorites TEXT,
        lastResetDate TEXT
      )
    ''');

    // After creating the table, insert the seed data
    for (var item in _seedData) {
      await db.insert('dop_menu', item.toMap());
    }
  }

  Future<int> update(DopMenu item) async {
    final db = await instance.database;
  
    return db.update(
      'dop_menu',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'dop_menu',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //USER DATA
  Future<UserProfile?> getUser() async {
    final db = await instance.database;
    final maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) return UserProfile.fromMap(maps.first);
    return null;
  }

  Future<int> createUser(UserProfile user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<int> updateUser(UserProfile user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> addPoints(int amount) async {
    final db = await instance.database;
    // This increments totalPoints by the amount passed
    await db.rawUpdate(
      'UPDATE users SET totalPoints = totalPoints + ? WHERE id = (SELECT id FROM users LIMIT 1)',
      [amount]
    );
  }

  Future<void> checkAndResetDailyPoints() async {
    final db = await instance.database;
    final user = await getUser();
    if (user == null) return;
  
    String today = DateTime.now().toString().split(' ')[0]; // Returns "2026-01-01"
  
    if (user.lastResetDate != today) {
      // It's a new day! Reset points and update the reset date.
      await db.update(
        'users',
        {
          'totalPoints': 0,
          'lastResetDate': today,
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
  }

  Future<void> toggleFavorite(int itemId) async {
    final db = await instance.database;
    final user = await getUser();
    if (user == null) return;
  
    List<int> favorites = List.from(user.favoriteIds);
  
    if (favorites.contains(itemId)) {
      favorites.remove(itemId);
    } else {
      favorites.add(itemId);
    }
  
    await db.update(
      'users',
      {'favorites': favorites.join(',')},
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}

// The comprehensive seed list
final List<DopMenu> _seedData = [
  // --- STARTERS ---
  DopMenu(category: MenuCategory.starter, title: 'Jumping Jacks', description: 'Get your heart rate up quickly.', image: 'assets/images/Jumping_Jacks.png'),
  DopMenu(category: MenuCategory.starter, title: 'Short Walk', description: 'A quick 5-minute stroll.', image: 'assets/images/short_walk.png'),
  DopMenu(category: MenuCategory.starter, title: 'Stretching or Yoga', description: 'Loosen up your muscles.', image: 'assets/images/stretching.png'),
  DopMenu(category: MenuCategory.starter, title: 'Dancing', description: 'Play one song and just move.', image: 'assets/images/dance.png'),
  DopMenu(category: MenuCategory.starter, title: 'Listening to Music', description: 'Put on your favorite upbeat track.', image: 'assets/images/music.png'),
  DopMenu(category: MenuCategory.starter, title: 'Coffee or Tea', description: 'Savor a warm beverage.', image: 'assets/images/coffee.png'),
  DopMenu(category: MenuCategory.starter, title: 'Petting your Pet', description: 'Instant oxytocin boost.', image: 'assets/images/petting_pet.png'),
  DopMenu(category: MenuCategory.starter, title: 'Watching Birds', description: 'Look out the window for a few minutes.', image: 'assets/images/birdwatching.png'),
  DopMenu(category: MenuCategory.starter, title: 'Meditation', description: 'Quick mindfulness check-in.', image: 'assets/images/meditation.png'),
  DopMenu(category: MenuCategory.starter, title: 'Breathing Exercises', description: 'Try the 4-7-8 technique.', image: 'assets/images/breathing.png'),
  DopMenu(category: MenuCategory.starter, title: 'Reading', description: 'Read two pages of a book.', image: 'assets/images/reading.png'),
  DopMenu(category: MenuCategory.starter, title: 'Puzzle/Brain Teaser', description: 'Solve a quick riddle or Sudoku.', image: 'assets/images/puzzle.png'),
  DopMenu(category: MenuCategory.starter, title: 'Drawing or Doodling', description: 'Let your pen wander.', image: 'assets/images/doodles.png'),
  DopMenu(category: MenuCategory.starter, title: 'Journal', description: 'Write down three things.', image: 'assets/images/journaling.png'),
  DopMenu(category: MenuCategory.starter, title: 'Collect Dishes', description: 'Clear the room of cups and plates.', image: 'assets/images/dish_gathering.png'),
  DopMenu(category: MenuCategory.starter, title: 'Clear a Surface', description: 'Pick one table or desk area.', image: 'assets/images/clearing_clutter.png'),
  DopMenu(category: MenuCategory.starter, title: 'Pickup Clothes', description: 'Get the laundry off the floor.', image: 'assets/images/pick_up_clothes.png'),
  DopMenu(category: MenuCategory.starter, title: 'Organize 5ft Area', description: 'Tidy a very small corner.', image: 'assets/images/clear_5ft_area.png'),
  DopMenu(category: MenuCategory.starter, title: 'Eating a Snack', description: 'Fuel your body.', image: 'assets/images/eating_snack.png'),
  DopMenu(category: MenuCategory.starter, title: 'Refreshing Beverage', description: 'Ice cold water or juice.', image: 'assets/images/coffee.png'),
  DopMenu(category: MenuCategory.starter, title: 'Calling a Friend', description: 'A quick 5-minute catch up.', image: 'assets/images/call_friend.png'),
  DopMenu(category: MenuCategory.starter, title: 'Brief Conversation', description: 'Chat with a neighbor or roommate.', image: 'assets/images/conversation.png'),
  DopMenu(category: MenuCategory.starter, title: 'Face Mask', description: 'Refresh your skin.', image: 'assets/images/facemask.png'),
  DopMenu(category: MenuCategory.starter, title: 'Quick Shower', description: 'A fast temperature reset.', image: 'assets/images/shower.png'),

  // --- ENTREES ---
  DopMenu(category: MenuCategory.entree, title: 'Exercise 💪', description: 'Full workout or gym session.', points: 50, image: 'assets/images/Jumping_Jacks.png'),
  DopMenu(category: MenuCategory.entree, title: 'Work on a Hobby 🧠/💪', description: 'Deep dive into what you love.', points: 40, image: 'assets/images/hobby.png'),
  DopMenu(category: MenuCategory.entree, title: 'Clean a Room 💪', description: 'Top to bottom deep clean.', points: 45, image: 'assets/images/cleaning.png'),
  DopMenu(category: MenuCategory.entree, title: 'Purge Closet 🧠', description: 'Declutter your wardrobe.', points: 50, image: 'assets/images/cleaning.png'),
  DopMenu(category: MenuCategory.entree, title: 'Yardwork 💪', description: 'Mow, weed, or plant.', points: 40, image: 'assets/images/yardwork.png'),
  DopMenu(category: MenuCategory.entree, title: 'Read a Book 🧠', description: 'Get lost in a few chapters.', points: 30, image: 'assets/images/reading.png'),

  // --- SIDES ---
  DopMenu(category: MenuCategory.side, title: 'Listen to Music', description: 'Background vibes while working.', points: 10, image: 'assets/images/music.png'),
  DopMenu(category: MenuCategory.side, title: 'Listen to Audiobook', description: 'Learn while you do chores.', points: 20, image: 'assets/images/audiobook.png'),
  DopMenu(category: MenuCategory.side, title: 'Healthy Snack', description: 'Berries or fresh fruit.', points: 15, image: 'assets/images/eating_snack.png'),
  DopMenu(category: MenuCategory.side, title: 'Body Doubling', description: 'Work alongside someone else.', points: 20, image: 'assets/images/bodydouble.png'),

  // --- DESSERTS ---
  DopMenu(category: MenuCategory.dessert, title: 'Watch TV', description: 'Enjoy a show guilt-free.', points: 2, image: 'assets/images/tv.png'),
  DopMenu(category: MenuCategory.dessert, title: 'TikTok/Reels', description: 'Short-form entertainment.', points: 2, image: 'assets/images/phone.png'),
  DopMenu(category: MenuCategory.dessert, title: 'Play Games', description: 'Video games or board games.', points: 2, image: 'assets/images/videogames.png'),
  DopMenu(category: MenuCategory.dessert, title: 'Shopping', description: 'Browse or buy something nice.', points: 2, image: 'assets/images/shopping.png'),
];