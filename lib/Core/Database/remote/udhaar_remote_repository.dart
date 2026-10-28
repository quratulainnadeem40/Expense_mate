import 'package:supabase_flutter/supabase_flutter.dart';

class UdhaarRemoteRepository {
  final SupabaseClient supabase;

  UdhaarRemoteRepository(this.supabase);

  static const String tableName = 'udhaar_entries';

  // ------------------------------------------------------------
  // GET ALL ENTRIES
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getEntries(String userId) async {
    final response = await supabase
        .from(tableName)
        .select()
        .eq('user_id', userId)
        .order('entry_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ------------------------------------------------------------
  // GET ENTRY BY ID
  // ------------------------------------------------------------

  Future<Map<String, dynamic>?> getEntryById({
    required String userId,
    required String entryId,
  }) async {
    final response = await supabase
        .from(tableName)
        .select()
        .eq('id', entryId)
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  // ------------------------------------------------------------
  // INSERT / UPSERT ENTRY
  // ------------------------------------------------------------

  Future<void> insertEntry(Map<String, dynamic> entry) async {
    await supabase.from(tableName).upsert(entry, onConflict: 'id');
  }

  // ------------------------------------------------------------
  // UPDATE ENTRY
  // ------------------------------------------------------------

  Future<void> updateEntry({
    required String entryId,
    required String userId,
    required Map<String, dynamic> entry,
  }) async {
    await supabase
        .from(tableName)
        .update(entry)
        .eq('id', entryId)
        .eq('user_id', userId);
  }

  // ------------------------------------------------------------
  // DELETE ENTRY
  // ------------------------------------------------------------

  Future<void> deleteEntry({
    required String entryId,
    required String userId,
  }) async {
    await supabase
        .from(tableName)
        .delete()
        .eq('id', entryId)
        .eq('user_id', userId);
  }
}
