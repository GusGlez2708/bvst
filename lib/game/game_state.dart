import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton class to manage global game state including coins and upgrades
class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  // Supabase client
  final _supabase = Supabase.instance.client;

  // Local storage for guest mode
  SharedPreferences? _prefs;
  bool _isGuestMode = false;

  // Local cache of game state
  int _coins = 0;
  int _doubleShotCharges = 0;
  int _invincibilityCharges = 0;
  bool _isLoaded = false;

  // Pricing constants
  static const int coinsPerEnemyKill = 50;
  static const int doubleShotCost = 100;
  static const int invincibilityCost = 50;

  // Getters
  int get coins => _coins;
  int get doubleShotCharges => _doubleShotCharges;
  int get invincibilityCharges => _invincibilityCharges;

  /// Load user's game state from Supabase or local storage
  Future<void> loadGameState() async {
    try {
      // Initialize SharedPreferences if not already done
      _prefs ??= await SharedPreferences.getInstance();
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('No user logged in, using guest mode with local storage');
        _isGuestMode = true;
        await _loadFromLocal();
        return;
      }

      // User is authenticated, load from Supabase
      _isGuestMode = false;
      final response = await _supabase
          .from('users')
          .select('coins, double_shot_charges, invincibility_charges')
          .eq('id', user.id)
          .single();

      _coins = response['coins'] ?? 0;
      _doubleShotCharges = response['double_shot_charges'] ?? 0;
      _invincibilityCharges = response['invincibility_charges'] ?? 0;
      _isLoaded = true;

      print('Game state loaded: $_coins coins, $_doubleShotCharges double shot charges, $_invincibilityCharges invincibility charges');
    } catch (e) {
      print('Error loading game state: $e');
      _resetToDefaults();
    }
  }

  /// Load game state from local storage (guest mode)
  Future<void> _loadFromLocal() async {
    _coins = _prefs?.getInt('guest_coins') ?? 0;
    _doubleShotCharges = _prefs?.getInt('guest_double_shot_charges') ?? 0;
    _invincibilityCharges = _prefs?.getInt('guest_invincibility_charges') ?? 0;
    _isLoaded = true;
    print('💾 Loaded guest state: $_coins coins, $_doubleShotCharges DS charges, $_invincibilityCharges INV charges');
  }

  /// Save game state to local storage (guest mode)
  Future<void> _saveToLocal() async {
    await _prefs?.setInt('guest_coins', _coins);
    await _prefs?.setInt('guest_double_shot_charges', _doubleShotCharges);
    await _prefs?.setInt('guest_invincibility_charges', _invincibilityCharges);
    print('💾 Saved guest state: $_coins coins');
  }

  /// Add coins (e.g., from killing enemies or purchases)
  Future<void> addCoins(int amount) async {
    _coins += amount;
    print('💰 Adding $amount coins. New total: $_coins');

    if (_isGuestMode) {
      await _saveToLocal();
      print('✓ Coins saved to local storage (guest mode)');
    } else {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Cannot add coins: User not authenticated');
      }
      await _syncCoins();
      print('✓ Coins successfully synced to database');
    }
  }

  /// Purchase double shot (adds 1 charge)
  Future<bool> purchaseDoubleShot() async {
    if (_coins < doubleShotCost) {
      print('Not enough coins for double shot');
      return false;
    }

    try {
      _coins -= doubleShotCost;
      _doubleShotCharges++;
      
      if (_isGuestMode) {
        await _saveToLocal();
        print('Double shot purchased (guest mode): $_doubleShotCharges charges');
      } else {
        final user = _supabase.auth.currentUser;
        if (user == null) return false;
        
        // Directly update database
        await _supabase.from('users').update({
          'coins': _coins,
          'double_shot_charges': _doubleShotCharges,
        }).eq('id', user.id);
        
        print('Double shot purchased: $_doubleShotCharges charges');
      }
      
      return true;
    } catch (e) {
      print('Error purchasing double shot: $e');
      return false;
    }
  }

  /// Purchase invincibility (adds 1 charge)
  Future<bool> purchaseInvincibility() async {
    if (_coins < invincibilityCost) {
      print('Not enough coins for invincibility');
      return false;
    }

    try {
      _coins -= invincibilityCost;
      _invincibilityCharges++;
      
      if (_isGuestMode) {
        await _saveToLocal();
        print('Invincibility purchased (guest mode): $_invincibilityCharges charges');
      } else {
        final user = _supabase.auth.currentUser;
        if (user == null) return false;
        
        // Directly update database
        await _supabase.from('users').update({
          'coins': _coins,
          'invincibility_charges': _invincibilityCharges,
        }).eq('id', user.id);
        
        print('Invincibility purchased: $_invincibilityCharges charges');
      }
      
      return true;
    } catch (e) {
      print('Error purchasing invincibility: $e');
      return false;
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
    _doubleShotCharges = 0;
    _invincibilityCharges = 0;
    _isLoaded = true;
  }
}
