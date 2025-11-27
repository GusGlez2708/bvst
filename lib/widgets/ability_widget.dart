import 'package:bvst/game/battle_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget showing available abilities with cooldowns and activation buttons
class AbilityWidget extends StatefulWidget {
  final BattleGame game;

  const AbilityWidget({super.key, required this.game});

  @override
  State<AbilityWidget> createState() => _AbilityWidgetState();
}

class _AbilityWidgetState extends State<AbilityWidget> {
  @override
  void initState() {
    super.initState();
    // Refresh UI every frame to update cooldowns
    widget.game.add(
      _RefreshTimer(
        onTick: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final abilities = widget.game.abilities;

    return Positioned(
      top: 60,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Double Shot Ability
          if (abilities.doubleShotUnlocked)
            _buildAbilityButton(
              icon: Icons.offline_bolt,
              label: 'Disparo Doble',
              status: abilities.getDoubleShotStatus(),
              canActivate: abilities.canActivateDoubleShot,
              isActive: abilities.doubleShotActive,
              onTap: () {
                if (abilities.activateDoubleShot()) {
                  setState(() {});
                }
              },
            ),
          const SizedBox(height: 10),
          // Extra Heart Ability
          if (abilities.extraHeartUnlocked)
            _buildAbilityButton(
              icon: Icons.favorite,
              label: 'Corazón Extra',
              status: abilities.getExtraHeartStatus(),
              canActivate: abilities.canUseExtraHeart,
              isActive: false,
              onTap: () {
                if (abilities.useExtraHeart()) {
                  widget.game.player.healHeart();
                  setState(() {});
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAbilityButton({
    required IconData icon,
    required String label,
    required String status,
    required bool canActivate,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    bool pulsate = false;

    if (isActive) {
      // Active state - bright green
      backgroundColor = const Color(0xFF00FF00).withOpacity(0.9);
      borderColor = const Color(0xFFFFFFFF);
      iconColor = Colors.black;
      pulsate = true;
    } else if (canActivate) {
      // Ready to activate - bright orange
      backgroundColor = const Color(0xFFFF9500).withOpacity(0.9);
      borderColor = const Color(0xFFFFFFFF);
      iconColor = Colors.white;
      pulsate = true;
    } else {
      // On cooldown or no uses - dark gray
      backgroundColor = const Color(0xFF444444).withOpacity(0.7);
      borderColor = const Color(0xFF888888);
      iconColor = const Color(0xFFAAAAAA);
    }

    return GestureDetector(
      onTap: canActivate ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: pulsate ? 3 : 2),
          boxShadow: pulsate
              ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: iconColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper component to trigger UI refresh every frame
class _RefreshTimer extends Component {
  final VoidCallback onTick;
  _RefreshTimer({required this.onTick});

  @override
  void update(double dt) {
    onTick();
  }
}
