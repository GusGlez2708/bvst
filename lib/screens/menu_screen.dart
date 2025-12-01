import 'package:bvst/game/audio_manager.dart';
import 'package:bvst/services/progress_service.dart'; // Import ProgressService
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Inicia la música del menú
    AudioManager().playMenuBgm();

    // Initialize video background
    _videoController =
        VideoPlayerController.asset('assets/cinematicas/MenuDinamic.mp4')
          ..setLooping(true)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isVideoInitialized = true;
              });
              _videoController.play();
            }
          });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      AudioManager().pauseMenuBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioManager().resumeMenuBgm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. VIDEO DE FONDO (LOOPING) ---
          Positioned.fill(
            child: _isVideoInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
          ),

          // --- 2. COLUMNA DE BOTONES (POSICIONADA) ---
          Align(
            // Ajusta este valor vertical para mover los botones arriba/abajo.
            // Empezamos con 0.3 (30% abajo del centro) como base.
            // Si el título aún se tapa, puedes probar 0.4 o 0.5.
            alignment: const Alignment(
              0.0,
              0.4,
            ), // Centrado H, un poco más abajo del centro V
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // La columna solo ocupa el espacio necesario
              children: [
                // Botón JUGAR
                _buildStyledButton(
                  text: 'JUGAR',
                  onTap: () async {
                    // AudioManager().playUiSfx('start.mp3'); // <-- REMOVED: User requested BGM only

                    final progressService = ProgressService();
                    final savedLevel = await progressService.getSavedLevel();

                    // Level 1 has cinematic
                    if (savedLevel == 1) {
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          '/cinematic',
                          arguments: {
                            'videoPath': 'assets/cinematicas/WakeUpLeve1.mp4',
                            'nextRoute': '/game',
                          },
                        );
                      }
                      return;
                    }

                    // Other levels go directly to game (no cinematics yet)
                    String route = '/game';
                    if (savedLevel == 2) route = '/game_lvl2';
                    if (savedLevel == 3) route = '/game_lvl3';
                    if (savedLevel == 4) route = '/game_lvl4';
                    if (savedLevel == 5) route = '/game_lvl5';

                    if (context.mounted) {
                      Navigator.pushNamed(context, route);
                    }
                  },
                ),
                const SizedBox(height: 15), // Espacio entre botones (reducido)
                // Botón TIENDA
                _buildStyledButton(
                  text: 'TIENDA',
                  onTap: () {
                    Navigator.pushNamed(context, '/shop').then((_) {
                      // Al regresar de la tienda, reiniciar música del menú
                      AudioManager().playMenuBgm();
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Botón OPCIONES
                _buildStyledButton(
                  text: 'OPCIONES',
                  onTap: () {
                    Navigator.pushNamed(context, '/options');
                  },
                ),
                const SizedBox(height: 15),

                // Botón CRÉDITOS
                _buildStyledButton(
                  text: 'CRÉDITOS',
                  onTap: () {
                    Navigator.pushNamed(context, '/credits');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// --- WIDGET AUXILIAR PARA LOS BOTONES CON EL ESTILO DE LA IMAGEN 2 ---
  Widget _buildStyledButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // **TAMAÑO DE LOS BOTONES REDUCIDO**
        width: 200, // Ancho más pequeño
        height: 45, // Alto más pequeño
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco
          borderRadius: BorderRadius.circular(
            8,
          ), // Bordes ligeramente redondeados
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2,
          ), // Borde gris claro
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // Sombra para dar profundidad
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.pressStart2p(
                // Fuente que ya usabas
                color: const Color(0xFF2C3454), // Color de texto azul oscuro
                fontSize: 14, // Tamaño de fuente más pequeño
                fontWeight: FontWeight.bold,
              ),
            ),
            // --- SIMULACIÓN DE LOS "REMACHES" ---
            // Remache superior izquierdo
            Positioned(top: 5, left: 5, child: _buildRivets()),
            // Remache superior derecho
            Positioned(top: 5, right: 5, child: _buildRivets()),
            // Remache inferior izquierdo
            Positioned(bottom: 5, left: 5, child: _buildRivets()),
            // Remache inferior derecho
            Positioned(bottom: 5, right: 5, child: _buildRivets()),
          ],
        ),
      ),
    );
  }

  /// Widget para crear un "remache" individual
  Widget _buildRivets() {
    return Container(
      width: 8, // Tamaño del remache
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade600, // Color oscuro del remache
        shape: BoxShape.circle, // Forma circular
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }
}
