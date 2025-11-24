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
      text: "¿Crees que puedes apagarme? ¡Soy el fuego que te mantiene vivo!",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "No eres vida, eres destrucción. Me quemas por dentro.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "¡Te defiendo! Cuando te lastimaron, yo fui quien gritó. ¿Y así me pagas?",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Gritar no sanó nada. Solo alejó a quienes intentaron ayudar.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "¡Pues que se alejen! ¡Solo me necesitas a mí y a mi furia!",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Ya no quiero arder. Quiero paz.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  static final List<DialogueLine> level2Outro = [
    const DialogueLine(
      speaker: "Ira",
      text: "¡Aaaargh!… ¿Por qué… te calmas?… ¡Debes estar furioso!",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Estoy cansado de estar enojado. Suelto esta carga.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "Sin mí… serás débil… te pisotearán…",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Seré más fuerte porque podré pensar con claridad.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ira",
      text: "El fuego… se apaga… pero las cenizas… quedan…",
      portraitAsset: "assets/images/enemigo_lvl2.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "De las cenizas nacerá algo nuevo. Adiós, Ira.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  // --- Level 3: Tristeza ---
  static final List<DialogueLine> level3Intro = [
    const DialogueLine(
      speaker: "Tristeza",
      text: "¿Para qué luchar?… Todo termina igual… en silencio y olvido.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Lucho para recordar que aún hay luz, aunque tú la ocultes.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Tristeza",
      text: "Es tan pesado… levántate si puedes… pero es mejor quedarse aquí, en el suelo.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Me he levantado antes. Y lo haré mil veces más.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Tristeza",
      text: "Tus lágrimas son mías. Eres un mar de dolor… ahógate con nosotros.",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Nadaré hasta la orilla. No dejaré que me hundas.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  static final List<DialogueLine> level3Outro = [
    const DialogueLine(
      speaker: "Tristeza",
      text: "Sniff… te vas… me dejas sola otra vez…",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "No te dejo sola. Te acepto, pero no dejaré que me controles.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Tristeza",
      text: "El mundo es gris… sin esperanza…",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "El mundo tiene colores que tú no me dejabas ver.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Tristeza",
      text: "Quizás… descansar un poco… no esté mal…",
      portraitAsset: "assets/images/enemigo_lvl3.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Descansa. Yo seguiré caminando hacia el sol.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  // --- Level 4: Ansiedad ---
  static final List<DialogueLine> level4Intro = [
    const DialogueLine(
      speaker: "Ansiedad",
      text: "¿Y si fallas? ¿Y si todos se ríen? ¡No estás listo! ¡Nunca lo estarás!",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Basta. Esas voces no son reales. Son solo ruido.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ansiedad",
      text: "¡Cuidado! ¡Todo es peligroso! ¡El futuro es un abismo!",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "El futuro no existe aún. Solo importa este momento.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ansiedad",
      text: "¡No puedes respirar! ¡El aire se acaba! ¡Corre, huye, escóndete!",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Respiro profundo. Estoy aquí. Estoy a salvo. Y te enfrentaré.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
  ];

  static final List<DialogueLine> level4Outro = [
    const DialogueLine(
      speaker: "Ansiedad",
      text: "¡No, no, no! ¿Qué pasará ahora? ¡No hay plan! ¡Caos!",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Pasará lo que tenga que pasar. Y lo afrontaré cuando llegue.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ansiedad",
      text: "Pero… ¿y si…? ¿Y si…?",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Y si todo sale bien. Y si soy feliz.",
      portraitAsset: "assets/images/prota.png",
      side: DialogueSide.hero,
    ),
    const DialogueLine(
      speaker: "Ansiedad",
      text: "El ruido… se calla… es… extraño…",
      portraitAsset: "assets/images/enemigo_lvl4.png",
      side: DialogueSide.enemy,
    ),
    const DialogueLine(
      speaker: "Echo",
      text: "Es silencio. Es paz. Finalmente, soy libre.",
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
      default:
        return level1Outro;
    }
  }
}
