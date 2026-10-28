import 'package:supabase_flutter/supabase_flutter.dart';

class CommitteeRemoteRepository {
  final SupabaseClient supabase;

  CommitteeRemoteRepository(this.supabase);

  static const String tableName = 'committees';

  // ------------------------------------------------------------
  // GET ALL COMMITTEES
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getCommittees(String userId) async {
    final response = await supabase
        .from(tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ------------------------------------------------------------
  // GET COMMITTEE BY ID
  // ------------------------------------------------------------

  Future<Map<String, dynamic>?> getCommitteeById({
    required String userId,
    required String committeeId,
  }) async {
    final response = await supabase
        .from(tableName)
        .select()
        .eq('id', committeeId)
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  // ------------------------------------------------------------
  // INSERT / UPSERT COMMITTEE
  // ------------------------------------------------------------

  Future<void> insertCommittee(Map<String, dynamic> committee) async {
    await supabase.from(tableName).upsert(committee, onConflict: 'id');
  }

  // ------------------------------------------------------------
  // UPDATE COMMITTEE
  // ------------------------------------------------------------

  Future<void> updateCommittee({
    required String committeeId,
    required String userId,
    required Map<String, dynamic> committee,
  }) async {
    await supabase
        .from(tableName)
        .update(committee)
        .eq('id', committeeId)
        .eq('user_id', userId);
  }

  // ------------------------------------------------------------
  // DELETE COMMITTEE
  // ------------------------------------------------------------

  Future<void> deleteCommittee({
    required String committeeId,
    required String userId,
  }) async {
    await supabase
        .from(tableName)
        .delete()
        .eq('id', committeeId)
        .eq('user_id', userId);
  }
}
