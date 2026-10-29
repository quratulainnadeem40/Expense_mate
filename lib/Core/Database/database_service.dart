import 'database_provider.dart';
import 'app_database.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  bool _initialized = false;

  /// Returns the single shared Drift database instance.
  AppDatabase get database {
    return DatabaseProvider.instance.database;
  }

  /// Initializes the shared database.
  Future<void> init() async {
    if (_initialized) return;

    // IMPORTANT:
    // Do NOT create AppDatabase() here.
    // DatabaseProvider owns the single database instance.
    DatabaseProvider.instance.database;

    _initialized = true;
  }

  /// Closes the single shared database.
  Future<void> close() async {
    if (!_initialized) return;

    await DatabaseProvider.instance.close();
    _initialized = false;
  }
}