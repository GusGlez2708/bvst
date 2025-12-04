// lib/services/score_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _scoresKey = 'infinite_scores';
  static const String _usernameKey = 'player_username';

  /// Save a score from infinite mode (locally)
  Future<bool> saveInfiniteScore(int score, int roundReached) async {
    try {
      print('💾 Saving score locally...');
      print('💾 Score: $score, Round: $roundReached');

      final prefs = await SharedPreferences.getInstance();

      // Get current username (from login or default)
      final username = prefs.getString(_usernameKey) ?? 'Jugador';

      // Get existing scores
      final scoresJson = prefs.getString(_scoresKey) ?? '[]';
      final List<dynamic> scoresList = jsonDecode(scoresJson);

      // Add new score
      scoresList.add({
        'username': username,
        'score': score,
        'round': roundReached,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Sort by score (highest first)
      scoresList.sort(
        (a, b) => (b['score'] as int).compareTo(a['score'] as int),
      );

      // Keep only top 100
      if (scoresList.length > 100) {
        scoresList.removeRange(100, scoresList.length);
      }

      // Save back
      await prefs.setString(_scoresKey, jsonEncode(scoresList));

      print('✅ Score saved locally: $score (Round $roundReached)');
      return true;
    } catch (e) {
      print('❌ Error saving score: $e');
      return false;
    }
  }

  /// Set username (called after login)
  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  /// Get current username
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? 'Jugador';
  }

  /// Get user's personal score history (last 10)
  Future<List<Map<String, dynamic>>> getUserScores({int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = await getUsername();

      final scoresJson = prefs.getString(_scoresKey) ?? '[]';
      final List<dynamic> allScores = jsonDecode(scoresJson);

      // Filter by username
      final userScores = allScores
          .where((s) => s['username'] == username)
          .take(limit)
          .map((s) => Map<String, dynamic>.from(s))
          .toList();

      return userScores;
    } catch (e) {
      print('❌ Error getting user scores: $e');
      return [];
    }
  }

  /// Get user's best score
  Future<Map<String, dynamic>?> getUserBestScore() async {
    try {
      final userScores = await getUserScores(limit: 1);
      return userScores.isNotEmpty ? userScores.first : null;
    } catch (e) {
      print('❌ Error getting best score: $e');
      return null;
    }
  }

  /// Get global leaderboard (top scores from all users)
  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({
    int limit = 100,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = prefs.getString(_scoresKey) ?? '[]';
      final List<dynamic> scoresList = jsonDecode(scoresJson);

      return scoresList
          .take(limit)
          .map(
            (s) => {
              'username': s['username'],
              'score': s['score'],
              'round_reached': s['round'],
              'created_at': s['timestamp'],
            },
          )
          .toList();
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return [];
    }
  }

  /// Get user's rank in global leaderboard
  Future<Map<String, dynamic>?> getUserRank() async {
    try {
      final username = await getUsername();
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = prefs.getString(_scoresKey) ?? '[]';
      final List<dynamic> scoresList = jsonDecode(scoresJson);

      // Find user's best score position
      int rank = 0;
      for (int i = 0; i < scoresList.length; i++) {
        if (scoresList[i]['username'] == username) {
          rank = i + 1;
          break;
        }
      }

      if (rank == 0) return null;

      return {'rank': rank, 'total_players': scoresList.length};
    } catch (e) {
      print('❌ Error getting user rank: $e');
      return null;
    }
  }

  /// Clear all scores (for testing)
  Future<void> clearAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoresKey);
    print('🗑️ All scores cleared');
  }
}
