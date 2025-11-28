import 'package:bvst/game/game_state.dart';
import 'package:flame/components.dart';

/// Manages player abilities including cooldowns and limited uses
class AbilityManager extends Component {
  // Double Shot ability - now consumable (single use)
  int doubleShotCharges = 0;
  bool doubleShotActive = false;
  double doubleShotDuration = 10.0; // Active for 10 seconds
  double doubleShotTimeRemaining = 0; // Time remaining for active effect

  // Invincibility ability - now consumable (single use)
  int invincibilityCharges = 0;
  bool invincibilityActive = false;
  double invincibilityDuration = 7.0; // Active for 7 seconds
  double invincibilityTimeRemaining = 0; // Time remaining for active effect

  AbilityManager({
    required this.doubleShotCharges,
    required this.invincibilityCharges,
  });

  @override
  void update(double dt) {
    super.update(dt);

    // Update Double Shot timer
    if (doubleShotActive) {
      doubleShotTimeRemaining -= dt;
      if (doubleShotTimeRemaining <= 0) {
        doubleShotActive = false;
        print('⚔️ Double Shot deactivated');
      }
    }

    // Update Invincibility timer
    if (invincibilityActive) {
      invincibilityTimeRemaining -= dt;
      if (invincibilityTimeRemaining <= 0) {
        invincibilityActive = false;
        print('🛡️ Invincibility deactivated');
      }
    }
  }

  /// Activate Double Shot ability (consumes 1 charge)
  bool activateDoubleShot() {
    if (doubleShotCharges <= 0) {
      print('❌ No Double Shot charges available');
      return false;
    }

    if (doubleShotActive) {
      print('❌ Double Shot already active');
      return false;
    }

    doubleShotActive = true;
    doubleShotTimeRemaining = doubleShotDuration;
    doubleShotCharges--; // Local decrement for immediate feedback
    
    // Persist consumption
    GameState().consumeDoubleShot();
    
    print('⚔️ Double Shot activated! Charges remaining: $doubleShotCharges');
    return true;
  }

  /// Activate Invincibility ability (consumes 1 charge)
  bool activateInvincibility() {
    if (invincibilityCharges <= 0) {
      print('❌ No Invincibility charges available');
      return false;
    }

    if (invincibilityActive) {
      print('❌ Invincibility already active');
      return false;
    }

    invincibilityActive = true;
    invincibilityTimeRemaining = invincibilityDuration;
    invincibilityCharges--; // Local decrement for immediate feedback
    
    // Persist consumption
    GameState().consumeInvincibility();
    
    print('🛡️ Invincibility activated! Charges remaining: $invincibilityCharges');
    return true;
  }

  /// Check if Double Shot can be activated
  bool get canActivateDoubleShot => doubleShotCharges > 0 && !doubleShotActive;

  /// Check if Invincibility can be activated
  bool get canActivateInvincibility =>
      invincibilityCharges > 0 && !invincibilityActive;

  /// Get Double Shot status for UI
  String getDoubleShotStatus() {
    if (doubleShotCharges == 0) return 'COMPRAR';
    if (doubleShotActive) {
      return '${doubleShotTimeRemaining.toStringAsFixed(1)}s';
    }
    return 'x$doubleShotCharges';
  }

  /// Get Invincibility status for UI
  String getInvincibilityStatus() {
    if (invincibilityCharges == 0) return 'COMPRAR';
    if (invincibilityActive) {
      return '${invincibilityTimeRemaining.toStringAsFixed(1)}s';
    }
    return 'x$invincibilityCharges';
  }

  /// Check if Double Shot is unlocked (has at least 1 charge)
  bool get doubleShotUnlocked => doubleShotCharges > 0;

  /// Check if Invincibility is unlocked (has at least 1 charge)
  bool get invincibilityUnlocked => invincibilityCharges > 0;
}
