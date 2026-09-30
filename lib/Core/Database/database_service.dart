import 'app_database.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  late final AppDatabase database;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    database = AppDatabase();
    _initialized = true;
  }

  Future<void> close() async {
    if (!_initialized) return;

    await database.close();
    _initialized = false;
  }
}