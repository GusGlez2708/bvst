import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton class to manage global game state including coins and upgrades
class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  // Supabase client
  final _supabase = Supabase.instance.client;

  // Local cache of game state
  int _coins = 0;
  bool _hasDoubleShot = false;
  int _extraHeartsPurchased = 0;
  bool _isLoaded = false;

  // Pricing constants
  static const int coinsPerEnemyKill = 50;
  static const int doubleShotCost = 100;
  static const int extraHeartCost = 50;
  static const int maxExtraHeartsPerSession = 1;

  // Getters
  int get coins => _coins;
  bool get hasDoubleShot => _hasDoubleShot;
  int get extraHeartsPurchased => _extraHeartsPurchased;
  bool get canPurchaseExtraHeart =>
      _extraHeartsPurchased < maxExtraHeartsPerSession;

  /// Load user's game state from Supabase
  Future<void> loadGameState() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('No user logged in, using default state');
        _resetToDefaults();
        return;
      }

      final response = await _supabase
          .from('users')
          .select('coins, has_double_shot, extra_hearts_purchased')
          .eq('id', user.id)
          .single();

      _coins = response['coins'] ?? 0;
      _hasDoubleShot = response['has_double_shot'] ?? false;
      _extraHeartsPurchased = response['extra_hearts_purchased'] ?? 0;
      _isLoaded = true;

      print('Game state loaded: $_coins coins, double shot: $_hasDoubleShot');
    } catch (e) {
      print('Error loading game state: $e');
      _resetToDefaults();
    }
  }

  /// Add coins (e.g., from killing enemies or purchases)
  Future<void> addCoins(int amount) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot add coins: User not authenticated');
    }

    _coins += amount;
    print('💰 Adding $amount coins. New total: $_coins');

    await _syncCoins();
    print('✓ Coins successfully synced to database');
  }

  /// Attempt to purchase double shot
  Future<bool> purchaseDoubleShot() async {
    if (_hasDoubleShot) {
      print('Double shot already purchased');
      return false;
    }

    if (_coins < doubleShotCost) {
      print('Not enough coins for double shot');
      return false;
    }

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Use the purchase_item function from SQL
      final result = await _supabase.rpc(
        'purchase_item',
        params: {
          'user_id': user.id,
          'item_cost': doubleShotCost,
          'item_type': 'double_shot',
        },
      );

      if (result == true) {
        _coins -= doubleShotCost;
        _hasDoubleShot = true;
        print('Double shot purchased successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('Error purchasing double shot: $e');
      return false;
    }
  }

  /// Attempt to purchase extra heart
  Future<bool> purchaseExtraHeart() async {
    if (!canPurchaseExtraHeart) {
      print('Already purchased max extra hearts for this session');
      return false;
    }

    if (_coins < extraHeartCost) {
      print('Not enough coins for extra heart');
      return false;
    }

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Use the purchase_item function from SQL
      final result = await _supabase.rpc(
        'purchase_item',
        params: {
          'user_id': user.id,
          'item_cost': extraHeartCost,
          'item_type': 'extra_heart',
        },
      );

      if (result == true) {
        _coins -= extraHeartCost;
        _extraHeartsPurchased++;
        print('Extra heart purchased successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('Error purchasing extra heart: $e');
      return false;
    }
  }

  /// Reset session-specific purchases (call when starting new game)
  Future<void> resetSessionPurchases() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.rpc(
        'reset_session_purchases',
        params: {'user_id': user.id},
      );

      _extraHeartsPurchased = 0;
      print('Session purchases reset');
    } catch (e) {
      print('Error resetting session purchases: $e');
    }
  }

  /// Sync coins to database - throws on error instead of silently failing
  Future<void> _syncCoins() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot sync coins: User not authenticated');
    }

    try {
      await _supabase.from('users').update({'coins': _coins}).eq('id', user.id);
      print('💾 Synced $_coins coins to database for user ${user.email}');
    } catch (e) {
      print('✗ Error syncing coins to database: $e');
      throw Exception('Failed to sync coins to database: $e');
    }
  }

  /// Reset to default values
  void _resetToDefaults() {
    _coins = 0;
    _hasDoubleShot = false;
    _extraHeartsPurchased = 0;
    _isLoaded = true;
  }
}
