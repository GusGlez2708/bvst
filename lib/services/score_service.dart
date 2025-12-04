// lib/services/score_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ScoreService {
  final _supabase = Supabase.instance.client;

  /// Save a score from infinite mode
  Future<bool> saveInfiniteScore(int score, int roundReached) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ Cannot save score: User not authenticated');
        return false;
      }

      await _supabase.from('infinite_scores').insert({
        'user_id': user.id,
        'score': score,
        'round_reached': roundReached,
      });

      print('✅ Score saved: $score (Round $roundReached)');
      return true;
    } catch (e) {
      print('❌ Error saving score: $e');
      return false;
    }
  }

  /// Get user's personal score history (last 10)
  Future<List<Map<String, dynamic>>> getUserScores({int limit = 10}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ Cannot get scores: User not authenticated');
        return [];
      }

      final response = await _supabase
          .from('infinite_scores')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting user scores: $e');
      return [];
    }
  }

  /// Get user's best score
  Future<Map<String, dynamic>?> getUserBestScore() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('infinite_scores')
          .select()
          .eq('user_id', user.id)
          .order('score', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error getting best score: $e');
      return null;
    }
  }

  /// Get global leaderboard (top scores)
  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({
    int limit = 100,
  }) async {
    try {
      final response = await _supabase
          .from('leaderboard_infinite')
          .select()
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return [];
    }
  }

  /// Get user's rank in global leaderboard
  Future<Map<String, dynamic>?> getUserRank() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .rpc('get_user_rank', params: {'p_user_id': user.id})
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error getting user rank: $e');
      return null;
    }
  }
}
