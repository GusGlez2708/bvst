import 'package:flame/components.dart';

/// Manages player abilities including cooldowns and limited uses
class AbilityManager extends Component {
  // Double Shot ability
  bool doubleShotUnlocked = false;
  bool doubleShotActive = false;
  double doubleShotDuration = 10.0; // Active for 10 seconds
  double doubleShotCooldown = 30.0; // 30 second cooldown
  double doubleShotTimeRemaining = 0; // Time remaining for active effect
  double doubleShotCooldownRemaining = 0; // Time remaining for cooldown

  // Extra Heart ability
  bool extraHeartUnlocked = false;
  int extraHeartsAvailable = 0; // How many uses available

  AbilityManager({
    required this.doubleShotUnlocked,
    required this.extraHeartUnlocked,
    required this.extraHeartsAvailable,
  });

  @override
  void update(double dt) {
    super.update(dt);

    // Update Double Shot timers
    if (doubleShotActive) {
      doubleShotTimeRemaining -= dt;
      if (doubleShotTimeRemaining <= 0) {
        doubleShotActive = false;
        doubleShotCooldownRemaining = doubleShotCooldown;
        print('⚔️ Double Shot deactivated');
      }
    }

    if (doubleShotCooldownRemaining > 0) {
      doubleShotCooldownRemaining -= dt;
      if (doubleShotCooldownRemaining < 0) {
        doubleShotCooldownRemaining = 0;
      }
    }
  }

  /// Activate Double Shot ability
  bool activateDoubleShot() {
    if (!doubleShotUnlocked) {
      print('❌ Double Shot not unlocked');
      return false;
    }

    if (doubleShotActive) {
      print('❌ Double Shot already active');
      return false;
    }

    if (doubleShotCooldownRemaining > 0) {
      print(
        '❌ Double Shot on cooldown: ${doubleShotCooldownRemaining.toStringAsFixed(1)}s',
      );
      return false;
    }

    doubleShotActive = true;
    doubleShotTimeRemaining = doubleShotDuration;
    print('⚔️ Double Shot activated for ${doubleShotDuration}s!');
    return true;
  }

  /// Use Extra Heart ability (heal 1 heart)
  bool useExtraHeart() {
    if (!extraHeartUnlocked) {
      print('❌ Extra Heart not unlocked');
      return false;
    }

    if (extraHeartsAvailable <= 0) {
      print('❌ No Extra Hearts available');
      return false;
    }

    extraHeartsAvailable--;
    print('❤️ Extra Heart used! Remaining: $extraHeartsAvailable');
    return true;
  }

  /// Check if Double Shot can be activated
  bool get canActivateDoubleShot =>
      doubleShotUnlocked &&
      !doubleShotActive &&
      doubleShotCooldownRemaining <= 0;

  /// Check if Extra Heart can be used
  bool get canUseExtraHeart => extraHeartUnlocked && extraHeartsAvailable > 0;

  /// Get Double Shot status for UI
  String getDoubleShotStatus() {
    if (!doubleShotUnlocked) return 'LOCKED';
    if (doubleShotActive) {
      return '${doubleShotTimeRemaining.toStringAsFixed(1)}s';
    }
    if (doubleShotCooldownRemaining > 0) {
      return '${doubleShotCooldownRemaining.toStringAsFixed(0)}s';
    }
    return 'READY';
  }

  /// Get Extra Heart status for UI
  String getExtraHeartStatus() {
    if (!extraHeartUnlocked) return 'LOCKED';
    return 'x$extraHeartsAvailable';
  }
}
