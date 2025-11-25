import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DialogueSide { hero, enemy }

class DialogueLine {
  final String speaker;
  final String text;
  final String portraitAsset;
  final DialogueSide side;

  const DialogueLine({
    required this.speaker,
    required this.text,
    required this.portraitAsset,
    required this.side,
  });
}

class DialogueOverlay extends StatefulWidget {
  final List<DialogueLine> lines;
  final VoidCallback onFinished;

  const DialogueOverlay({
    super.key,
    required this.lines,
    required this.onFinished,
  });

  @override
  State<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay> {
  int _currentLineIndex = 0;
  String _displayedText = "";
  int _charIndex = 0;
  Timer? _typewriterTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _typewriterTimer?.cancel();
    _displayedText = "";
    _charIndex = 0;
    _isTyping = true;

    final fullText = widget.lines[_currentLineIndex].text;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < fullText.length) {
        setState(() {
          _displayedText += fullText[_charIndex];
          _charIndex++;
        });
      } else {
        _stopTyping();
      }
    });
  }

  void _stopTyping() {
    _typewriterTimer?.cancel();
    setState(() {
      _isTyping = false;
      _displayedText = widget.lines[_currentLineIndex].text;
    });
  }

  void _handleTap() {
    if (_isTyping) {
      // If typing, show full line immediately
      _stopTyping();
    } else {
      // If finished typing, go to next line
      if (_currentLineIndex < widget.lines.length - 1) {
        setState(() {
          _currentLineIndex++;
        });
        _startTyping();
      } else {
        // No more lines, finish dialogue
        widget.onFinished();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLine = widget.lines[_currentLineIndex];
    final isHero = currentLine.side == DialogueSide.hero;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          height: 200, // Fixed height for dialogue area
          color: Colors.black.withOpacity(0.8), // Semi-transparent background
          padding: const EdgeInsets.all(16.0),
          child: Row(
            textDirection: isHero ? TextDirection.ltr : TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Portrait
              Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: AssetImage(currentLine.portraitAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Speaker Name
                    Text(
                      currentLine.speaker,
                      style: GoogleFonts.orbitron(
                        color: isHero ? Colors.blueAccent : Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: isHero ? TextAlign.left : TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    // Dialogue Text
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _displayedText,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                          textAlign: isHero ? TextAlign.left : TextAlign.right,
                        ),
                      ),
                    ),
                    // "Tap to continue" hint
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _isTyping ? "..." : "▼",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Dialogue Data ---

class DialogueData {
  // --- Level 1: Miedo ---
  static final List<DialogueLine> level1Intro = [
    const DialogueLine(
      speaker: "Miedo",
      text: "Sabía que vendrías… Siempre corres hacia lo que te asusta.",
      portraitAsset: "assets/images/enemigo_lvl1.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "No te conozco, pero siento el pecho apretado solo con mirarte…",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Miedo",
      text: "Porque yo soy ese peso. Cada vez que dudabas, cada noche sin dormir… estaba contigo.",
      portraitAsset: "assets/images/enemigo_lvl1.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Si eres parte de mí, ¿por qué quieres destruir este lugar?",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Miedo",
      text: "Porque me abandonaste aquí. Me encerraste en Viridis para no sentirme nunca más. Ahora te toca enfrentarme… o volver a huir.",
      portraitAsset: "assets/images/enemigo_lvl1.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Esta vez no voy a correr.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  static final List<DialogueLine> level1Outro = [
    const DialogueLine(
      speaker: "Miedo",
      text: "Aun… aquí… sigues temblando por dentro.",
      portraitAsset: "assets/images/enemigo_lvl1.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Sí. Pero ahora sé que el miedo no desaparece por esconderlo.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Miedo",
      text: "Recuerdas el primer fragmento, ¿verdad?… La ciudad en llamas… la decisión que no tomaste…",
      portraitAsset: "assets/images/enemigo_lvl1.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Solo veo sombras… pero siento que fue culpa mía.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Miedo",
      text: "Sigue adelante. Los demás no serán tan misericordiosos como yo.",
      portraitAsset: "assets/images/enemigo_lvl1.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Si esto fue solo el miedo… ¿qué me espera después?",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  // --- Level 2: Ira ---
  static final List<DialogueLine> level2Intro = [
    const DialogueLine(
      speaker: "Ira",
      text: "Por fin. El cobarde que dejó que todo ardiera.",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "¿Cobarde? Acabo de destruir a mi propio miedo.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "Y aun así sigues dudando. Yo recuerdo lo que hiciste después del desastre…",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "No lo recuerdo. Solo flashes de fuego y ecos de gritos.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "Golpeaste puertas, gritaste órdenes, culpaste a todos menos a ti. Me alimentaste hasta volverme un incendio imposible de apagar.",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Si de verdad soy responsable… entonces tengo que verte de frente.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "Perfecto. Déjame arder en ti una última vez.",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
  ];

  static final List<DialogueLine> level2Outro = [
    const DialogueLine(
      speaker: "Ira",
      text: "Aun… puedes luchar sin destruirlo todo…",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "La rabia me dio fuerza… pero también me hizo ciego.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "Recuerdas un poco más, ¿no? La discusión en el laboratorio, las advertencias que ignoraste…",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Presioné para activar Viridis antes de tiempo… porque no soportaba ver morir a más gente.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "Y por eso nos condenaste aquí. Ve con Silencio… él sabe lo que callaste después.",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
  ];

  // --- Level 3: Silencio ---
  static final List<DialogueLine> level3Intro = [
    const DialogueLine(
      speaker: "Silencio",
      text: "… … …",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "¿No vas a decir nada? Después de Miedo e Ira, hablar sería lo mínimo.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Silencio",
      text: "…Tus palabras llegaron tarde. Tus decisiones también.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "¿Eres el eco de lo que no dije?",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Silencio",
      text: "Eres tú mirando las alarmas, escuchando las advertencias… y decidiendo no contárselo a nadie. El sistema fallaba, y tú lo sabías.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Si lo hubiera dicho… ¿podría haber detenido el colapso?",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Silencio",
      text: "…No lo sabrás si sigues callando. Rompe este silencio, Echo.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
  ];

  static final List<DialogueLine> level3Outro = [
    const DialogueLine(
      speaker: "Silencio",
      text: "…Al fin… hablas.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Fallaba la contención de las conciencias… y yo lo oculté para poder activar Viridis.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Silencio",
      text: "Tenías miedo de perder tu proyecto… y a las personas que confiaron en ti.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Guardé silencio y los encerré en un sistema inestable. Por eso las emociones se corrompieron…",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Silencio",
      text: "Queda alguien que lleva todo ese peso… Culpa te espera al fondo de Viridis.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
  ];

  // --- Level 4: Culpa ---
  static final List<DialogueLine> level4Intro = [
    const DialogueLine(
      speaker: "Culpa",
      text: "Por fin llegas. Pensé que seguirías encontrando excusas para no mirar atrás.",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Ya recuerdo demasiado como para huir. Eres el que no me deja dormir… incluso aquí dentro.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Culpa",
      text: "Fuiste tú quien aprobó subir sus conciencias. Fuiste tú quien apretó el botón. Familias enteras confiaron en ti.",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Creí que Viridis los protegería…",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Culpa",
      text: "Y los atrapaste en un infierno digital. Yo nací el día que viste los primeros errores y decidiste seguir adelante.",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Si tengo que cargar con eso… lo haré. Pero no voy a quedarme congelado.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Culpa",
      text: "Entonces demuéstralo. No con palabras, sino con lo que hagas después de vencerme.",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
  ];

  static final List<DialogueLine> level4Outro = [
    const DialogueLine(
      speaker: "Culpa",
      text: "No puedes borrarme… solo aceptarme.",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Lo sé. Lo que hice no se deshace. Pero puedo decidir qué hacer ahora con Viridis.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Culpa",
      text: "Has reunido todos los fragmentos. Miedo, Ira, Silencio y yo… todos formamos parte de la misma persona.",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "¿Y Conciencia?",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Culpa",
      text: "Conciencia es el juez… y el guardián de este mundo. Es la parte de ti que nunca olvidó nada.",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Entonces es hora de enfrentarme conmigo mismo.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  // --- Level 5: Conciencia (JEFE FINAL) ---
  static final List<DialogueLine> level5Intro = [
    const DialogueLine(
      speaker: "Conciencia",
      text: "Llegaste más lejos de lo que esperaba, Echo.",
      portraitAsset: "assets/images/enemigo_lvl5.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Ya no necesito que me digan quién soy. Yo construí Viridis. Yo provoqué este encierro.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Conciencia",
      text: "Y aun así sigues aquí, luchando dentro del mismo sistema que te condenó. ¿Sabes por qué?",
      portraitAsset: "assets/images/enemigo_lvl5.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Porque quiero reparar el daño. Si tengo que apagar Viridis, lo haré.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Conciencia",
      text: "No es tan simple. Si destruyes este lugar, las conciencias atrapadas se perderán para siempre. Si lo estabilizas, vivirán en una mentira eterna.",
      portraitAsset: "assets/images/enemigo_lvl5.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Entonces, ¿qué eres exactamente? ¿Un enemigo… o la última oportunidad de decidir?",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Conciencia",
      text: "Soy la suma de tus elecciones. Para alcanzar una respuesta, primero tendrás que enfrentarte a mí… a ti mismo.",
      portraitAsset: "assets/images/enemigo_lvl5.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "He peleado contra mis emociones. Puedo pelear contra mi conciencia también.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Conciencia",
      text: "Muéstrame que aprendiste algo de cada uno de ellos.",
      portraitAsset: "assets/images/enemigo_lvl5.png",
      side: DialogueSide.enemy,
    ),
  ];

  static final List<DialogueLine> level5Outro = [
    const DialogueLine(
      speaker: "Conciencia",
      text: "Venciste… pero no desaparezco. La conciencia nunca se borra por completo.",
      portraitAsset: "assets/images/enemigo_lvl5.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "No quiero borrarte. Quiero decidir con claridad, no desde el miedo o la culpa.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Conciencia",
      text: "Entonces escucha: Viridis puede reescribirse. Puedes liberar las conciencias, pero será un salto al vacío… o puedes mantenerlas aquí, seguras pero encadenadas a un mundo falso.",
      portraitAsset: "assets/images/enemigo_lvl5.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Esta vez no voy a decidir solo por mí. Reescribiré el sistema… para darles una elección.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Conciencia",
      text: "…Esa era la respuesta que necesitaba escuchar.",
      portraitAsset: "assets/images/enemigo_lvl5.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Echoes of Viridis… no son solo voces del pasado. Serán la decisión de lo que venga después.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  static List<DialogueLine> getIntroForLevel(int level) {
    switch (level) {
      case 1:
        return level1Intro;
      case 2:
        return level2Intro;
      case 3:
        return level3Intro;
      case 4:
        return level4Intro;
      case 5:
        return level5Intro;
      default:
        return level1Intro;
    }
  }

  static List<DialogueLine> getOutroForLevel(int level) {
    switch (level) {
      case 1:
        return level1Outro;
      case 2:
        return level2Outro;
      case 3:
        return level3Outro;
      case 4:
        return level4Outro;
      case 5:
        return level5Outro;
      default:
        return level1Outro;
    }
  }
}
