import 'package:bvst/game/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Play credits music
    AudioManager().playGameBgm('creditos.mp3');
    
    // Start auto-scrolling after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    // Stop credits music and return to menu music
    AudioManager().stopGameBgm();
    AudioManager().playMenuBgm();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AudioManager().pauseGameBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioManager().resumeGameBgm();
    }
  }

  void _startAutoScroll() {
    const duration = Duration(seconds: 60); // Total scroll duration
    
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 2000,
      duration: duration,
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            // Credits scroll
            SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 100),
                child: Column(
                  children: [
                    const SizedBox(height: 200),
                    
                    // Title
                    _buildTitle('ECHOES OF VIRIDIS'),
                    const SizedBox(height: 150),

                    // Game Design
                    _buildRole('DISEÑO DE JUEGO'),
                    _buildName('JAVIER ROBERTO ANCONA ALEJO'),
                    _buildName('GUSTAVO ADOLFO GONZALEZ ROSAS'),
                    const SizedBox(height: 100),

                    // Programming
                    _buildRole('PROGRAMACIÓN'),
                    _buildName('JAVIER ROBERTO ANCONA ALEJO'),
                    _buildName('ANGEL ERNESTO NAVA SANCHEZ'),
                    const SizedBox(height: 100),

                    // Art & Graphics
                    _buildRole('ARTE Y GRÁFICOS'),
                    _buildName('GUSTAVO ADOLFO GONZALEZ ROSAS'),
                    _buildName('JAVIER ROBERTO ANCONA ALEJO'),
                    const SizedBox(height: 100),

                    // Sound Design
                    _buildRole('DISEÑO DE SONIDO'),
                    _buildName('ANGEL ERNESTO NAVA SANCHEZ'),
                    _buildName('GUSTAVO ADOLFO GONZALEZ ROSAS'),
                    const SizedBox(height: 100),

                    // Level Design
                    _buildRole('DISEÑO DE NIVELES'),
                    _buildName('JAVIER ROBERTO ANCONA ALEJO'),
                    _buildName('ANGEL ERNESTO NAVA SANCHEZ'),
                    const SizedBox(height: 100),

                    // Story
                    _buildRole('HISTORIA'),
                    _buildName('GUSTAVO ADOLFO GONZALEZ ROSAS'),
                    _buildName('JAVIER ROBERTO ANCONA ALEJO'),
                    const SizedBox(height: 100),

                    // UI/UX Design
                    _buildRole('DISEÑO DE INTERFAZ'),
                    _buildName('GUSTAVO ADOLFO GONZALEZ ROSAS'),
                    _buildName('ANGEL ERNESTO NAVA SANCHEZ'),
                    const SizedBox(height: 100),

                    // Game Testing
                    _buildRole('PRUEBAS DE JUEGO'),
                    _buildName('JAVIER ROBERTO ANCONA ALEJO'),
                    _buildName('GUSTAVO ADOLFO GONZALEZ ROSAS'),
                    const SizedBox(height: 100),

                    // Additional Design (Solo Bryan)
                    _buildRole('DISEÑO ADICIONAL'),
                    _buildName('BRYAN ALEXANDRA BASTARRACHEA SANCHEZ'),
                    const SizedBox(height: 150),

                    // Special Thanks
                    _buildRole('AGRADECIMIENTOS ESPECIALES'),
                    const SizedBox(height: 40),
                    _buildSmallName('A TODOS LOS QUE JUGARON'),
                    _buildSmallName('Y APOYARON ESTE PROYECTO'),
                    const SizedBox(height: 200),

                    // Final title
                    _buildFinalTitle('ECHOES OF VIRIDIS'),
                    const SizedBox(height: 100),
                    _buildSmallName('2025'),
                    
                    const SizedBox(height: 500),
                  ],
                ),
              ),
            ),

            // Back button (top left)
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Tap to close hint
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'TOCA PARA CERRAR',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.pressStart2p(
        color: Colors.white,
        fontSize: 24,
        letterSpacing: 4,
        shadows: [
          Shadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.pressStart2p(
        color: Colors.white,
        fontSize: 32,
        letterSpacing: 6,
        shadows: [
          Shadow(
            color: Colors.cyan.withOpacity(0.8),
            blurRadius: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildRole(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.pressStart2p(
        color: Colors.grey.shade400,
        fontSize: 12,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildName(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.pressStart2p(
          color: Colors.white,
          fontSize: 16,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallName(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.pressStart2p(
          color: Colors.grey.shade500,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
