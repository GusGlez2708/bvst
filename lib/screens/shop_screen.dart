import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/game/game_state.dart';
import 'package:bvst/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final GameState _gameState = GameState();
  bool _isLoading = true;
  
  // Animation
  int _currentBgIndex = 0;
  late Timer _animationTimer;
  final List<String> _bgImages = [
    'assets/images/shop_bg_1.png',
    'assets/images/shop_bg_2.png',
    'assets/images/shop_bg_3.png',
    'assets/images/shop_bg_4.png',
    'assets/images/shop_bg_5.png',
  ];

  // Ads
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _loadGameState();
    _startAnimation();
    _loadBannerAd();
    // Initialize Stripe (Mock setup for demo)
    // Stripe.publishableKey = "pk_test_..."; 
  }

  @override
  void dispose() {
    _animationTimer.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 333), (timer) {
      setState(() {
        _currentBgIndex = (_currentBgIndex + 1) % _bgImages.length;
      });
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );
    _bannerAd?.load();
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
      _showPurchaseDialog(true, '¡Compra exitosa!');
    } else {
      _showPurchaseDialog(false, 'No tienes suficientes monedas o ya lo compraste.');
    }
  }

  Future<void> _buyCoins(int amount, double priceMxn) async {
    AudioManager().playUiSfx('start.mp3');

    try {
      // 1. Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      // 2. Petición al Backend para obtener el PaymentIntent
      // NOTA: Usa '10.0.2.2' para emulador Android, o tu IP local para dispositivo físico.
      // Cuando despliegues, cambia esto por la URL de Render.
      const backendUrl = 'https://backend-stripe-fhvy.onrender.com/payment-sheet'; 
      
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (priceMxn * 100).toInt(), // Convertir a centavos
          'currency': 'mxn',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.body}');
      }

      final jsonResponse = json.decode(response.body);

      // Configurar la clave pública de Stripe
      Stripe.publishableKey = jsonResponse['publishableKey'];

      // 3. Inicializar Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['paymentIntent'],
          merchantDisplayName: 'BVST Game',
          customerId: jsonResponse['customer'],
          customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
          // style: ThemeMode.dark,
        ),
      );

      Navigator.pop(context); // Cerrar loading inicial

      // 4. Mostrar Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 5. Si llega aquí, el pago fue exitoso
      await _gameState.addCoins(amount);
      setState(() {});
      _showPurchaseDialog(true, '¡Has comprado $amount monedas!');

    } on StripeException catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context); // Cerrar loading si sigue abierto
      
      if (e.error.code == FailureCode.Canceled) {
        // El usuario canceló, no mostramos error feo
        print('Pago cancelado por el usuario');
      } else {
        _showPurchaseDialog(false, 'Error de Stripe: ${e.error.localizedMessage}');
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context); // Cerrar loading si sigue abierto
      _showPurchaseDialog(false, 'Error: $e');
    }
  }

  void _showPurchaseDialog(bool success, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          success ? '✓ Éxito' : '✗ Error',
          style: GoogleFonts.pressStart2p(
            color: success ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.pressStart2p(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.pressStart2p(color: Colors.amber, fontSize: 12),
            ),
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
          // Animated Background
          Positioned.fill(
            child: Image.asset(
              _bgImages[_currentBgIndex],
              fit: BoxFit.cover,
              gaplessPlayback: true, // Prevent flickering
              filterQuality: FilterQuality.none, // Pixel art style
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Scrollable Content
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Power-ups Title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'POWER-UPS',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(
                              color: Colors.cyanAccent,
                              fontSize: 20,
                              shadows: [const Shadow(color: Colors.blue, blurRadius: 10)],
                            ),
                          ),
                        ),
                      ),

                      // Power-ups Grid
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          delegate: SliverChildListDelegate([
                            _buildShopItem(
                              title: 'DISPARO DOBLE',
                              price: GameState.doubleShotCost,
                              icon: Icons.double_arrow,
                              alreadyOwned: _gameState.hasDoubleShot,
                              onPurchase: () => _purchaseItem('double_shot'),
                            ),
                            _buildShopItem(
                              title: 'CORAZÓN EXTRA',
                              price: GameState.extraHeartCost,
                              icon: Icons.favorite,
                              alreadyOwned: !_gameState.canPurchaseExtraHeart,
                              onPurchase: () => _purchaseItem('extra_heart'),
                            ),
                            // Placeholders for future items (to show 4 items as requested)
                            _buildShopItem(
                              title: 'IMÁN (WIP)',
                              price: 500,
                              icon: Icons.build, // Placeholder icon
                              alreadyOwned: false,
                              onPurchase: () {},
                              isLocked: true,
                            ),
                            _buildShopItem(
                              title: 'ESCUDO (WIP)',
                              price: 500,
                              icon: Icons.shield,
                              alreadyOwned: false,
                              onPurchase: () {},
                              isLocked: true,
                            ),
                          ]),
                        ),
                      ),

                      // Coin Shop Title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                          child: Text(
                            'TIENDA DE MONEDAS',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(
                              color: Colors.amberAccent,
                              fontSize: 20,
                              shadows: [const Shadow(color: Colors.orange, blurRadius: 10)],
                            ),
                          ),
                        ),
                      ),

                      // Coin Shop Items
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 items per row
                            childAspectRatio: 0.6,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          delegate: SliverChildListDelegate([
                            _buildCoinShopItem(
                              amount: 400,
                              priceMxn: 10.0, // Mínimo de Stripe para MXN es ~$10
                              imagePath: 'assets/images/coin_bucket.png',
                              title: 'Cubo',
                            ),
                            _buildCoinShopItem(
                              amount: 600,
                              priceMxn: 20.0,
                              imagePath: 'assets/images/gold_container.png',
                              title: 'Caja',
                            ),
                            _buildCoinShopItem(
                              amount: 1000,
                              priceMxn: 50.0,
                              imagePath: 'assets/images/gold_wheelbarrow.png',
                              title: 'Carretilla',
                            ),
                          ]),
                        ),
                      ),
                      
                      // Bottom padding for Ad
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back Button (Top Left)
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // Banner Ad (Bottom)
          if (_isBannerReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        children: [
          Text(
            'TIENDA',
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 32,
              shadows: [
                Shadow(
                  color: Colors.purple.withOpacity(0.8),
                  offset: const Offset(3, 3),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                const SizedBox(width: 10),
                Text(
                  '${_gameState.coins}',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.amber,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem({
    required String title,
    required int price,
    required IconData icon,
    required bool alreadyOwned,
    required VoidCallback onPurchase,
    bool isLocked = false,
  }) {
    final canAfford = _gameState.coins >= price;
    final canPurchase = canAfford && !alreadyOwned && !isLocked;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: alreadyOwned ? Colors.green : (isLocked ? Colors.grey : Colors.cyan),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (alreadyOwned ? Colors.green : Colors.cyan).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: alreadyOwned ? Colors.green : (isLocked ? Colors.grey : Colors.white),
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (alreadyOwned)
            Text(
              'LISTO',
              style: GoogleFonts.pressStart2p(color: Colors.green, fontSize: 10),
            )
          else if (isLocked)
             Text(
              'WIP',
              style: GoogleFonts.pressStart2p(color: Colors.grey, fontSize: 10),
            )
          else
            GestureDetector(
              onTap: canPurchase ? onPurchase : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: canAfford ? Colors.amber : Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$price',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoinShopItem({
    required int amount,
    required double priceMxn,
    required String imagePath,
    required String title,
  }) {
    return GestureDetector(
      onTap: () => _buyCoins(amount, priceMxn),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amber, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 40, fit: BoxFit.contain),
            const SizedBox(height: 5),
            Text(
              title,
              style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8),
            ),
            const SizedBox(height: 5),
            Text(
              '+$amount',
              style: GoogleFonts.pressStart2p(color: Colors.amber, fontSize: 10),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '\$${priceMxn.toStringAsFixed(0)} MXN',
                style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
