import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/game_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final GameState _gameState = GameState();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameState();
  }

  Future<void> _loadGameState() async {
    await _gameState.loadGameState();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _purchaseItem(String itemType) async {
    bool success = false;

    if (itemType == 'double_shot') {
      success = await _gameState.purchaseDoubleShot();
    } else if (itemType == 'extra_heart') {
      success = await _gameState.purchaseExtraHeart();
    }

    if (success) {
      AudioManager().playUiSfx('start.mp3');
      setState(() {}); // Refresh UI
      _showPurchaseDialog(true, itemType);
    } else {
      _showPurchaseDialog(false, itemType);
    }
  }

  void _showPurchaseDialog(bool success, String itemType) {
    String message = success
        ? '¡Compra exitosa!'
        : 'No tienes suficientes monedas o ya lo compraste.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? '✓ Éxito' : '✗ Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/shop_background.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          // Dark overlay for better readability
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with title and coins
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'TIENDA',
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white,
                          fontSize: 32,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(3, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCoinsDisplay(),
                    ],
                  ),
                ),

                // Shop items
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildShopItem(
                            title: 'DISPARO DOBLE',
                            description: 'Dispara 2 balas a la vez',
                            price: GameState.doubleShotCost,
                            icon: Icons.double_arrow,
                            alreadyOwned: _gameState.hasDoubleShot,
                            onPurchase: () => _purchaseItem('double_shot'),
                          ),
                          const SizedBox(height: 30),
                          _buildShopItem(
                            title: 'CORAZÓN EXTRA',
                            description:
                                '+1 vida máxima (${_gameState.extraHeartsPurchased}/${GameState.maxExtraHeartsPerSession} comprado)',
                            price: GameState.extraHeartCost,
                            icon: Icons.favorite,
                            alreadyOwned: !_gameState.canPurchaseExtraHeart,
                            onPurchase: () => _purchaseItem('extra_heart'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Back button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildBackButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.amber, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
          const SizedBox(width: 15),
          Text(
            '${_gameState.coins}',
            style: GoogleFonts.pressStart2p(
              color: Colors.amber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem({
    required String title,
    required String description,
    required int price,
    required IconData icon,
    required bool alreadyOwned,
    required VoidCallback onPurchase,
  }) {
    final canAfford = _gameState.coins >= price;
    final canPurchase = canAfford && !alreadyOwned;

    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: alreadyOwned
              ? Colors.green
              : (canAfford ? Colors.white : Colors.grey),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: alreadyOwned
                ? Colors.green
                : (canAfford ? Colors.white : Colors.grey),
            size: 48,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.pressStart2p(
              color: Colors.grey[400],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (alreadyOwned)
            Text(
              'ADQUIRIDO',
              style: GoogleFonts.pressStart2p(
                color: Colors.green,
                fontSize: 14,
              ),
            )
          else
            ElevatedButton(
              onPressed: canPurchase ? onPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? Colors.amber : Colors.grey,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '$price',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        AudioManager().playUiSfx('start.mp3');
        Navigator.pop(context);
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'VOLVER',
            style: GoogleFonts.pressStart2p(
              color: const Color(0xFF2C3454),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
